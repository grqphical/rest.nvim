local curl = require("rest.curl")

---Splits a string based on a given delimiter character
---@param s string: String to split
---@param delimiter string: Character to split at
---@return table<string>
local function split(s, delimiter)
    if s == nil then
        return {}
    end

    local result               = {}
    local from                 = 1
    local delim_from, delim_to = string.find(s, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(s, from, delim_from - 1))
        from                 = delim_to + 1
        delim_from, delim_to = string.find(s, delimiter, from)
    end
    table.insert(result, string.sub(s, from))
    return result
end

local M = {}

local options = {}

local defaults = {
    default = {
        http_version = "HTTP/1.1",
        method = "GET",
        headers = {},
        body = "",
        cookies = {},
    },

    request_template = "#url:"
}

---@class rest.Request
---@field url string: URL to send the request to
---@field method string: HTTP method to use
---@field version string: HTTP version to use
---@field header table<string, string>: HTTP header
---@field body string: The HTTP Request Body
---@field cookies table<string> Cookies to send with request


local function parse_line(line)
    local result = {
        key = "",
        value = "",
        comment = false
    }

    local parsingKey = true
    for i = 1, #line do
        local char = line:sub(i, i)
        if i == 1 and char == "#" then
            result.comment = true
            return result
        end

        if char == ":" and parsingKey == true then
            parsingKey = false

            --- remove space after colon if it exists
            if #line >= i + 1 and line:sub(i + 1, i + 1) == " " then
                line = line:sub(1, i - 1) .. line:sub(i + 1)
            end
            goto continue
        end

        if parsingKey then
            result.key = result.key .. char
        else
            result.value = result.value .. char
        end
        ::continue::
    end

    return result
end

---@param contents table<string>
---@return rest.Request
M.__parse_rest_buffer = function(contents)
    local request = {
        method = options.default.method,
        header = options.default.headers,
        version = options.default.http_version,
        body = options.default.body,
        url = "",
        cookies = {},
    }

    for _, line in ipairs(contents) do
        local result = parse_line(line)
        if result.comment then
            goto continue
        end

        if result.key == "method" then
            request.method = result.value
        elseif result.key == "url" then
            request.url = result.value
        elseif result.key == "header" then
            table.insert(request.header, result.value)
        elseif result.key == "version" then
            request.version = result.value
        elseif result.key == "body" then
            request.body = result.value
        elseif result.key == "cookie" then
            table.insert(request.cookies, result.value)
        else
            vim.notify(string.format("unknown key: '%s'", result.key), vim.log.levels.ERROR, {})
        end
        ::continue::
    end

    return request
end

---@param system_completed vim.SystemCompleted
local function show_response(system_completed)
    vim.schedule(function()
        if system_completed.code ~= 0 then
            vim.notify(string.format("failed to send request: %s", system_completed.stderr), vim.log.levels.ERROR, {})
        end

        local buf = vim.fn.bufnr("Response")

        if buf == -1 then
            buf = vim.api.nvim_create_buf(true, false)
            vim.api.nvim_buf_set_name(buf, "Response")
        end

        vim.bo[buf].buftype = ""
        vim.bo[buf].modifiable = true

        local lines = vim.split(system_completed.stdout, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_set_option_value('modified', false, { buf = buf })
        vim.api.nvim_set_option_value('filetype', "rest.nvim-response", { buf = buf })

        vim.bo[buf].modifiable = false
        vim.api.nvim_set_current_buf(buf)
    end)
end

M.create_request = function()
    local current_buf = vim.api.nvim_get_current_buf()

    if vim.bo[current_buf].filetype == "Response" then
        vim.api.nvim_buf_delete(current_buf, { force = true })
    elseif vim.bo[current_buf].filetype == "rest.nvim" then
        vim.api.nvim_buf_delete(current_buf, { force = true })
    end

    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].buftype = ""


    vim.api.nvim_buf_set_name(buf, "rest.nvim")

    local lines = split(options.request_template, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_set_current_buf(buf)

    vim.api.nvim_set_option_value('modified', false, { buf = buf })
    vim.api.nvim_set_option_value('filetype', "rest.nvim-request", { buf = buf })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            local request = M.__parse_rest_buffer(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
            vim.api.nvim_set_option_value('modified', false, { buf = buf })

            if request.url == "" then
                vim.api.nvim_buf_delete(buf, { force = true })
                return
            end

            local cmd = curl.CommandBuilder:new():url(request.url)

            for _, value in ipairs(request.header) do
                cmd:header(value)
            end

            for _, value in ipairs(request.cookies) do
                cmd:cookie(value)
            end

            cmd:version(request.version)
            cmd:body(request.body)
            cmd:method(request.method)

            cmd:run(show_response)
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
    })
end

M.sendRequestFromCurrentBuffer = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local request = M.__parse_rest_buffer(lines)

    local cmd = curl.CommandBuilder:new():url(request.url)

    for _, value in ipairs(request.header) do
        cmd:header(value)
    end

    for _, value in ipairs(request.cookies) do
        cmd:cookie(cookie)
    end

    cmd:version(request.version)
    cmd:body(request.body)
    cmd:method(request.method)


    cmd:run(show_response)
end

M.saveData = function(o)
    local current_buf = vim.api.nvim_get_current_buf()

    if vim.bo[current_buf].filetype == "rest.nvim-request" then
        local path = o.args
        if path == "" then
            path = "./request"
        end
        local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

        local file = io.open(path, "w")
        if not file then
            vim.notify("Could not open file: " .. path, vim.log.levels.ERROR)
            return
        end

        for _, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()
        print("Saved request data to:", path)
    elseif vim.bo[current_buf].filetype == "rest.nvim-response" then
        local path = o.args
        if path == "" then
            path = "./response"
        end
        local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

        local file = io.open(path, "w")
        if not file then
            vim.notify("Could not open file: " .. path, vim.log.levels.ERROR)
            return
        end

        for _, line in ipairs(lines) do
            file:write(line .. "\n")
        end
        file:close()
        print("Saved response data to:", path)
    else
        print("not in request or response buffer")
    end
end

M.setup = function(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M

local curl = require("rest.curl")

local M = {}

local options = {

}

local defaults = {

}

---@class rest.Request
---@field url string: URL to send the request to
---@field method string: HTTP method to use
---@field version string: HTTP version to use
---@field header table<string, string>: HTTP header
---@field body string: The HTTP Request Body


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
        method = "GET",
        header = {
        },
        version = "HTTP/1.1",
        body = "",
        url = ""
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
        end
        ::continue::
    end

    return request
end

---@param system_completed vim.SystemCompleted
local function show_response(system_completed)
    if system_completed.code ~= 0 then
        error(string.format("curl failed to run: %s", system_completed.stderr))
    end

    vim.schedule(function()
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

local function delete_buffers_by_filetype(filetype, force)
    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(bufs) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
            local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
            if ft == filetype then
                if force then
                    vim.cmd("bdelete! " .. bufnr)
                else
                    vim.cmd("bdelete " .. bufnr)
                end
            end
        end
    end
end

M.create_request = function()
    delete_buffers_by_filetype("rest-nvim.response", true)

    local current_buf = vim.api.nvim_get_current_buf()

    if vim.bo[current_buf].filetype == "Response" then
        vim.api.nvim_buf_delete(current_buf, { force = true })
    elseif vim.bo[current_buf].filetype == "rest.nvim" then
        vim.api.nvim_buf_delete(current_buf, { force = true })
    end

    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].buftype = ""


    vim.api.nvim_buf_set_name(buf, "rest.nvim")

    vim.api.nvim_set_current_buf(buf)

    vim.api.nvim_set_option_value('modified', false, { buf = buf })
    vim.api.nvim_set_option_value('filetype', "rest.nvim-request", { buf = buf })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            local request = M.__parse_rest_buffer(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
            vim.api.nvim_set_option_value('modified', false, { buf = buf })

            local cmd = curl.CommandBuilder:new():url(request.url)

            for _, value in ipairs(request.header) do
                cmd:header(value)
            end

            cmd:version(request.version)
            cmd:body(request.body)
            cmd:method(request.method)

            cmd:run(show_response)
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
    })
end

M.saveData = function(o)
    local current_buf = vim.api.nvim_get_current_buf()
    print(vim.bo[current_buf].filetype)

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

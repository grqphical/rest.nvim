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
        value = ""
    }

    local parsingKey = true
    for i = 1, #line do
        local char = line:sub(i, i)
        if char == ":" then
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
            ["User-Agent"] = "rest.nvim/0.1.0 curl/7.54.1"
        },
        version = "HTTP/1.1",
        body = "",
        url = ""
    }

    for _, line in ipairs(contents) do
        local result = parse_line(line)
        if result.key == "method" then
            request.method = result.value
        elseif result.key == "url" then
            request.url = result.value
        elseif result.key == "header" then
            request.header[result.key] = result.value
        elseif result.key == "version" then
            request.version = result.value
        elseif result.key == "body" then
            request.body = result.value
        end
    end

    return request
end

---@param request rest.Request
local function send_request(request)

end

M.create_request = function()
    local buf = vim.api.nvim_create_buf(true, false)
    vim.bo[buf].buftype = ""

    vim.api.nvim_buf_set_name(buf, "New Request")

    vim.api.nvim_set_current_buf(buf)

    vim.api.nvim_set_option_value('modified', false, { buf = buf })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            local request = M.__parse_rest_buffer(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
            print(request.url, request.method, request.body)
            vim.api.nvim_set_option_value('modified', false, { buf = buf })
        end,
    })
end

M.setup = function(opts)
    options = vim.tbl_deep_extend("force", defaults, opts or {})

    vim.api.nvim_create_user_command("NewRequest", function()
        local rest = require("rest")

        rest.create_request()
    end, {})
end

return M

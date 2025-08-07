local M = {}

local function split(s, delimiter)
    delimiter = delimiter or '%s'
    local t = {}
    local i = 1
    for str in string.gmatch(s, '([^' .. delimiter .. ']+)') do
        t[i] = str
        i = i + 1
    end
    return t
end

---@class rest.Request
---@field url string URL to send the request to
---@field method string HTTP method to use
---@field version string HTTP version to use
---@field header table<string, string> HTTP header
---@field body string The HTTP Request Body

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

---@param contents string
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

    for line in split(contents, "\n") do
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

M.setup = function(config)
    print("Loaded rest.nvim")
end

return M

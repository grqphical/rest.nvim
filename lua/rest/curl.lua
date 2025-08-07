-- simple CURL wrapper for Lua

function iteratorToArray(...)
    local arr = {}
    for v in ... do
        arr[#arr + 1] = v
    end
    return arr
end

function table.clone(org)
    return { table.unpack(org) }
end

-- check if CURL is installed
if not vim.fn.executable("curl") then
    error("could not find curl command, ensure it is installed and added to your PATH")
end

---@class rest.curl.CommandBuilder
---@field _cmd string

local M = {}

---@return rest.curl.CommandBuilder
M.create_command_builder = function()
    local self = {
        _cmd = "curl",
    }

    ---@param url string
    ---@return self
    function self:url(url)
        self._cmd = self._cmd .. " " .. url
        return self
    end

    ---@param header string: A header key/pair value in the form key:value
    function self:header(header)
        self._cmd = self._cmd .. string.format("-H \"%s\"", header)
    end

    return self
end

return M

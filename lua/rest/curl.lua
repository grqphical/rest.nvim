-- simple CURL wrapper for Lua
function table.clone(org)
    return { table.unpack(org) }
end

-- check if CURL is installed
if not vim.fn.executable("curl") then
    error("could not find curl command, ensure it is installed and added to your PATH")
end

local M = {}

---@class rest.curl.CommandBuilder
---@field _cmd string


local CommandBuilder = {}
CommandBuilder.__index = CommandBuilder

---@return table
function CommandBuilder:new()
    local self = setmetatable({}, CommandBuilder)
    self._cmd = "curl"
    return self
end

---@param url string
---@return rest.curl.CommandBuilder
function CommandBuilder:url(url)
    self._cmd = self._cmd .. " " .. url
    return self
end

---@param header string: A header key/pair value in the form key:value
function CommandBuilder:header(header)
    self._cmd = self._cmd .. string.format("-H \"%s\"", header)
end

return M

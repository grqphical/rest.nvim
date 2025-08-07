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
---@field _cmd string[]
local CommandBuilder = {}
CommandBuilder.__index = CommandBuilder

---@return table
function CommandBuilder:new()
    local self = setmetatable({}, CommandBuilder)
    self._cmd = { "curl", "--verbose" }
    return self
end

---@param url string
---@return rest.curl.CommandBuilder
function CommandBuilder:url(url)
    table.insert(self._cmd, url)
    return self
end

---@param header string: A header key/pair value in the form key:value
---@return rest.curl.CommandBuilder
function CommandBuilder:header(header)
    table.insert(self._cmd, string.format("-H \"%s\"", header))
    return self
end

---@param on_exit function: function to run when the command finishes
function CommandBuilder:run(on_exit)
    for _, arg in ipairs(self._cmd) do
        print(arg)
    end

    local _, err = pcall(function() vim.system(self._cmd, { text = true }, on_exit) end)

    if err then
        error(string.format("unable to run curl: %s", err))
    end
end

M.CommandBuilder = CommandBuilder

return M

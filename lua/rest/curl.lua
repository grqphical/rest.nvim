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
    self._cmd = { "curl", "-i" }
    return self
end

---@param url string
---@return rest.curl.CommandBuilder
function CommandBuilder:url(url)
    table.insert(self._cmd, url)
    return self
end

---@param header string: key/pair value in form of key:pair
---@return rest.curl.CommandBuilder
function CommandBuilder:header(header)
    table.insert(self._cmd, "-H")
    table.insert(self._cmd, header)
    return self
end

---@param method string
---@return rest.curl.CommandBuilder
function CommandBuilder:method(method)
    table.insert(self._cmd, "-X")
    table.insert(self._cmd, method)
    return self
end

---@param body string
---@return rest.curl.CommandBuilder
function CommandBuilder:body(body)
    table.insert(self._cmd, "-d")
    table.insert(self._cmd, body)
    return self
end

---@param version string
---@return rest.curl.CommandBuilder
function CommandBuilder:version(version)
    local version_flag = ""
    if version == "HTTP/1.0" then
        version_flag = "--http1.0"
    elseif version == "HTTP/1.1" then
        version_flag = "--http1.1"
    elseif version == "HTTP/2" then
        version_flag = "--http2"
    elseif version == "HTTP/3" then
        version_flag = "--http3"
    else
        error("invalid HTTP version provided")
    end

    table.insert(self._cmd, version_flag)
end

---@param on_exit function: function to run when the command finishes
function CommandBuilder:run(on_exit)
    local _, err = pcall(function() vim.system(self._cmd, { text = true }, on_exit):wait(5000) end)

    if err then
        error(string.format("unable to run curl: %s", err))
    end
end

M.CommandBuilder = CommandBuilder

return M

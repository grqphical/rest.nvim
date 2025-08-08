local rest = require("rest")

vim.api.nvim_create_user_command("RestSave", rest.saveData, {
    nargs = "?",
    complete = "file",
})

vim.api.nvim_create_user_command("NewRequest", function()
    rest.create_request()
end, {})

-- enable highlights for request/response buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = "rest.nvim-request",
    callback = function()
        vim.cmd [[
            syn match restTag /^\s*\zs[^:]\+/

            syn keyword restMethod GET
            syn keyword restMethod POST
            syn keyword restMethod PATCH
            syn keyword restMethod PUT
            syn keyword restMethod DELETE
            syn keyword restMethod INFO
            syn keyword restMethod HEAD
            syn keyword restMethod OPTIONS
            syn keyword restMethod CONNECT
            syn keyword restMethod TRACE

            syn match restVersion /HTTP\/1.0/
            syn match restVersion /HTTP\/1.1/
            syn match restVersion /HTTP\/2/
            syn match restVersion /HTTP\/3/

            hi def link restTag Statement
            hi def link restMethod Constant
            hi def link restVersion Constant
        ]]
    end
})

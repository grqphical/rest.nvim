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
            syn match restTag /^\s*\zs\%(\l\|\u\)\+\ze:/

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

            hi def link restTag Label
            hi def link restMethod Constant
            hi def link restVersion Constant
        ]]
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "rest.nvim-response",
    callback = function()
        vim.cmd [[
            syn match restTag /^\s*\zs\%(\l\|\u\|-\)\+\ze:/

            syn match restStatusOk /\%1l2[0-9][0-9]/
            syn match restStatusError /\%1l4[0-9][0-9]/
            syn match restStatusError /\%1l5[0-9][0-9]/

            hi def link restStatusOk DiagnosticOK
            hi def link restStatusError Error
            hi def link restTag Label
        ]]
    end
})

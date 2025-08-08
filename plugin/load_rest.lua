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
            syn match restTag /^\s*[^:]*:\ze/
            hi def link restTag Statement
        ]]
    end
})

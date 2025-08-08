local rest = require("rest")

vim.api.nvim_create_user_command("RestSave", rest.saveData, {
    nargs = "?",
    complete = "file",
})

vim.api.nvim_create_user_command("NewRequest", function()
    rest.create_request()
end, {})

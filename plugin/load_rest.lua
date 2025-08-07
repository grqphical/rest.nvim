vim.api.nvim_create_user_command("NewRequest", function()
    local rest = require("rest")

    rest.create_request()
end, {})

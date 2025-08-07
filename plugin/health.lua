local health = vim.health or require("vim.health") -- fallback for older versions
print("loading healthcheck")
local M = {}

function M.check()
    health.start("rest.nvim health check")

    if vim.fn.executable("curl") == 1 then
        health.report_ok("curl is available")
    else
        health.report_error("curl not found", { "curl is required for rest.nvim" })
    end
end

return M

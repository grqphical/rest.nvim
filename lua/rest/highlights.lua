local M = {}

M.apply_request_highlights = function()
    vim.fn.matchadd("RestRequestPrefix", [[/\w\+:/]])
    vim.api.nvim_set_hl(0, "RestRequestPrefix", { guifg = "#00ccff" })
end

M.apply_response_highlights = function()

end

return M

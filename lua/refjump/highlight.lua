local M = {}

---Used to keep track of if LSP reference highlights should be enabled
local highlight_references = false

function M.enable_reference_highlights()
  vim.lsp.buf.document_highlight()
  highlight_references = true
end

function M.disable_reference_highlights()
  if not highlight_references then
    vim.lsp.buf.clear_references()
  else
    highlight_references = false
  end
end

function M.auto_clear_reference_highlights()
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged' }, {
    callback = M.disable_reference_highlights,
  })
end

return M

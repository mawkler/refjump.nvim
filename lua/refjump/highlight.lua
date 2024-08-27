local M = {}

---Used to keep track of if LSP reference highlights should be enabled
local highlight_references = false

local highlight_namespace = vim.api.nvim_create_namespace('RefjumpReferenceHighlights')

local reference_hl_name = 'RefjumpReference'

function M.create_fallback_hl_group(fallback_hl)
  local hl = vim.api.nvim_get_hl(0, { name = reference_hl_name })

  if vim.tbl_isempty(hl) then
    vim.api.nvim_set_hl(0, reference_hl_name, { link = fallback_hl })
  end
end

function M.enable_reference_highlights(references, bufnr)
  for _, ref in ipairs(references) do
    local line = ref.range.start.line
    local start_col = ref.range.start.character
    local end_col = ref.range['end'].character

    vim.api.nvim_buf_add_highlight(
      bufnr,
      highlight_namespace,
      reference_hl_name,
      line,
      start_col,
      end_col
    )
  end

  highlight_references = true
end

function M.disable_reference_highlights()
  if not highlight_references then
    vim.api.nvim_buf_clear_namespace(0, highlight_namespace, 0, -1)
  else
    highlight_references = false
  end
end

function M.auto_clear_reference_highlights()
  vim.api.nvim_create_autocmd({ 'CursorMoved', 'ModeChanged', 'BufLeave' }, {
    callback = M.disable_reference_highlights,
  })
end

return M

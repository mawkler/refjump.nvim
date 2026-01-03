local M = {}

---Namespace for counter virtual text extmarks
local counter_namespace = vim.api.nvim_create_namespace('RefjumpCounter')

---Name of the highlight group for the counter
local counter_hl_name = 'RefjumpCounter'

---Create highlight group linked to WarningMsg if it doesn't exist
function M.create_hl_group()
  local hl = vim.api.nvim_get_hl(0, { name = counter_hl_name })

  if vim.tbl_isempty(hl) then
    vim.api.nvim_set_hl(0, counter_hl_name, { link = 'WarningMsg' })
  end
end

---Show virtual text counter at the end of the current line
---@param current_index integer Current reference index (1-based)
---@param total_count integer Total number of references
---@param bufnr integer Buffer number
function M.show(current_index, total_count, bufnr)
  -- Get current cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- Convert to 0-indexed

  -- Clear any existing counter in this buffer
  M.clear(bufnr)

  -- Format the counter text
  local text = string.format(' [%d/%d]', current_index, total_count)

  -- Add virtual text at end of line
  vim.api.nvim_buf_set_extmark(bufnr, counter_namespace, line, 0, {
    virt_text = { { text, counter_hl_name } },
    virt_text_pos = 'eol',
    priority = 100,
  })
end

---Clear counter virtual text from buffer
---@param bufnr integer Buffer number (0 for current buffer)
function M.clear(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, counter_namespace, 0, -1)
end

return M

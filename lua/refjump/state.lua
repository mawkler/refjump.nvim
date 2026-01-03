local M = {}

---@class RefjumpBufferState
---@field references RefjumpReference[]
---@field current_index integer|nil

---Per-buffer state storage
---@type table<integer, RefjumpBufferState>
local buffer_states = {}

---Get or create state for a buffer
---@param bufnr integer
---@return RefjumpBufferState
local function get_buffer_state(bufnr)
  if not buffer_states[bufnr] then
    buffer_states[bufnr] = {
      references = {},
      current_index = nil,
    }
  end
  return buffer_states[bufnr]
end

---Get info about current reference position (for statusline use)
---@param bufnr? integer Buffer number (defaults to current buffer)
---@return { index: integer|nil, total: integer }
function M.get_reference_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local state = get_buffer_state(bufnr)
  return {
    index = state.current_index,
    total = #state.references,
  }
end

---Check if reference navigation is currently active
---@return boolean
function M.is_active()
  return require('refjump.highlight').is_active()
end

---Update state after jumping to a reference (internal use)
---@param references RefjumpReference[]
---@param current_index integer|nil
---@param bufnr? integer Buffer number (defaults to current buffer)
function M.set(references, current_index, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local state = get_buffer_state(bufnr)
  state.references = references or {}
  state.current_index = current_index
end

---Clear state for a buffer (internal use)
---@param bufnr? integer Buffer number (defaults to current buffer)
function M.clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  buffer_states[bufnr] = nil
end

---Clean up state when buffer is deleted
local function setup_buffer_cleanup()
  vim.api.nvim_create_autocmd('BufDelete', {
    group = vim.api.nvim_create_augroup('refjump_state_cleanup', { clear = true }),
    callback = function(event)
      buffer_states[event.buf] = nil
    end,
  })
end

setup_buffer_cleanup()

return M

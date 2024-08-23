local M = {}

local function jump_map(opts)
  return function()
    require('refjump').reference_jump(opts)
  end
end

function M.create_keymaps(opts)
  local nxo = { 'n', 'x', 'o' }

  vim.keymap.set(nxo, opts.keymaps.next, jump_map({ forward = true }), {})
  vim.keymap.set(nxo, opts.keymaps.prev, jump_map({ forward = false }), {})
end

return M

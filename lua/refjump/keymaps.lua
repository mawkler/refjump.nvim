local M = {}

local function jump_map(opts)
  return function()
    local current_position = vim.api.nvim_win_get_cursor(0)
    require('refjump').reference_jump(opts, current_position)
  end
end

local function repeatable_jump_map(opts)
  local repeatably_do = require('demicolon.jump').repeatably_do
  return function()
    local references
    repeatably_do(function(o)
      -- TODO: create and expose function that calculates current_position
      local current_position = vim.api.nvim_win_get_cursor(0)
      require('refjump').reference_jump(o, current_position, references, function(refs)
        references = refs
      end)
    end, opts)
  end
end

---@param opts RefjumpOptions
function M.create_keymaps(opts)
  local nxo = { 'n', 'x', 'o' }
  local demicolon_exists, _ = pcall(require, 'demicolon.jump')

  local jump = (opts.integrations.demicolon.enable and demicolon_exists)
      and repeatable_jump_map
      or jump_map

  vim.keymap.set(nxo, opts.keymaps.next, jump({ forward = true }), {})
  vim.keymap.set(nxo, opts.keymaps.prev, jump({ forward = false }), {})
end

return M

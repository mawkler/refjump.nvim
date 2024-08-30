local M = {}

---@class RefjumpKeymapOptions
---@field enable? boolean
---@field next? string Keymap to jump to next LSP reference
---@field prev? string Keymap to jump to previous LSP reference

---@class RefjumpHighlightOptions
---@field enable? boolean Highlight the LSP references on jump
---@field auto_clear boolean Automatically clear highlights when cursor moves

---@class RefjumpIntegrationOptions
---@field demicolon? { enable?: boolean } Make `]r`/`[r` repeatable with `;`/`,` using demicolon.nvim

---@class RefjumpOptions
---@field keymaps? RefjumpKeymapOptions
---@field highlights? RefjumpHighlightOptions
---@field integrations RefjumpIntegrationOptions
---@field verbose boolean Print message if no reference is found
local options = {
  keymaps = {
    enable = true,
    next = ']r',
    prev = '[r',
  },
  highlights = {
    enable = true,
    auto_clear = true,
  },
  integrations = {
    demicolon = {
      enable = true,
    },
  },
  verbose = true,
}

---@return RefjumpOptions
function M.get_options()
  return options
end

---@param opts? RefjumpOptions
function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})

  if options.keymaps.enable then
    require('refjump.keymaps').create_keymaps(options)
  end

  if options.highlights.enable then
    require('refjump.highlight').create_fallback_hl_group('LspReferenceText')

    if options.highlights.auto_clear then
      require('refjump.highlight').auto_clear_reference_highlights()
    end
  end
end

M.reference_jump = require('refjump.jump').reference_jump

return M

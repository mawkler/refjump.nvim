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

---@param references table[]
---@param forward boolean
---@param current_position integer[]
---@return table
local function find_next_reference(references, forward, current_position)
  local current_line = current_position[1] - 1
  local current_col = current_position[2]

  local next_reference
  if forward then
    next_reference = vim.iter(references):find(function(ref)
      local ref_pos = ref.range.start
      return ref_pos.line > current_line or (ref_pos.line == current_line and ref_pos.character > current_col)
    end)
  else
    next_reference = vim.iter(references):rfind(function(ref)
      local ref_pos = ref.range.start
      return ref_pos.line < current_line or (ref_pos.line == current_line and ref_pos.character < current_col)
    end)
  end

  return next_reference
end

---@param next_reference table
local function jump_to(next_reference)
  local uri = next_reference.uri or next_reference.targetUri
  if not uri then
    vim.notify('refjump.nvim: Invalid URI in LSP response', vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.uri_to_bufnr(uri)

  vim.fn.bufload(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
  vim.api.nvim_win_set_cursor(0, {
    next_reference.range.start.line + 1,
    next_reference.range.start.character,
  })

  -- Open folds if the reference is inside a fold
  vim.cmd('normal! zv')
end

---@param next_reference integer[]
---@param forward boolean
---@param references any[]
local function jump_to_next_reference(next_reference, forward, references)
  -- If no reference is found, loop around
  if not next_reference then
    next_reference = forward and references[1] or references[#references]
  end

  if next_reference then
    jump_to(next_reference)
  else
    vim.notify('refjump.nvim: Could not find the next reference', vim.log.levels.WARN)
  end
end

---@param references table[]
---@param forward boolean
---@param current_position integer[]
local function jump_to_next_reference_and_highlight(references, forward, current_position)
  local next_reference = find_next_reference(references, forward, current_position)
  jump_to_next_reference(next_reference, forward, references)

  if options.highlights.enable then
    require('refjump.highlight').enable_reference_highlights(references, 0)
  end
end

---Move cursor to next LSP reference in the current buffer if `forward` is
---`true`, otherwise move to the previous reference. If `references` is not
---`nil`, `references` is used to determine next position. If `references` is
---`nil` they will be requested from the LSP server and passed to
---`with_references`
---@param opts { forward: boolean }
---@param current_position integer[]
---@param references? table[]
---@param with_references? function(any[]) Called if `references` is `nil` with LSP references for item at `current_position`
function M.reference_jump(opts, current_position, references, with_references)
  opts = opts or { forward = true }

  -- If references have already been computed (i.e. we're repeating the jump)
  if references then
    jump_to_next_reference_and_highlight(references, opts.forward, current_position)
    return
  end

  local params = vim.lsp.util.make_position_params()
  local context = { includeDeclaration = true }
  params = vim.tbl_extend('error', params, { context = context })

  vim.lsp.buf_request(0, 'textDocument/references', params, function(err, refs, _, _)
    if err then
      vim.notify('refjump.nvim: LSP Error: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    if not refs or vim.tbl_isempty(refs) then
      if options.verbose then
        vim.notify('No references found', vim.log.levels.INFO)
      end
      return
    end

    jump_to_next_reference_and_highlight(refs, opts.forward, current_position)

    if with_references then
      with_references(refs)
    end
  end)
end

---@param opts RefjumpOptions
function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts)

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

return M

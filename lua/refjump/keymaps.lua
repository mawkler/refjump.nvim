local M = {}

local function jump_map(opts)
  return function()
    require('refjump').reference_jump(opts)
  end
end

local function repeatable_jump_map(opts)
  local repeatably_do = require('demicolon.jump').repeatably_do
  return function()
    local references
    repeatably_do(function(o)
      require('refjump').reference_jump(o, references, function(refs)
        references = refs
      end)
    end, opts)
  end
end

---@param opts RefjumpOptions
function M.create_keymaps_autocmd(opts)
  -- Create keymaps only for buffers with LSP that supports documentHighlight
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('refjump_lsp_attach', {}),
    ---@param event { buf: number, data: { client_id: number } }
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local supports_document_highlight = client and client:supports_method(
        'textDocument/documentHighlight',
        event.buf
      )
      if not supports_document_highlight then
        return
      end

      local nxo = { 'n', 'x', 'o' }
      local demicolon_exists, _ = pcall(require, 'demicolon.jump')
      local jump = (opts.integrations.demicolon.enable and demicolon_exists)
          and repeatable_jump_map
          or jump_map

      vim.keymap.set(nxo, opts.keymaps.next, jump({ forward = true }), {
        desc = 'Next reference',
        buffer = event.buf,
      })

      vim.keymap.set(nxo, opts.keymaps.prev, jump({ forward = false }), {
        desc = 'Previous reference',
        buffer = event.buf,
      })
    end,
  })
end

return M

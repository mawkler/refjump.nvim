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
function M.create_keymaps(opts)
  local nxo = { 'n', 'x', 'o' }
  local demicolon_exists, _ = pcall(require, 'demicolon.jump')

  local jump = (opts.integrations.demicolon.enable and demicolon_exists)
      and repeatable_jump_map
      or jump_map

  -- Create keymaps only for buffers with lsp that supports documentHighlight
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup('refjump_lsp_attach', {}),
    ---@param event { buf: number, data: { client_id: number } }
    callback = function(event)
      local client_id = event.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)

      if client and client.supports_method('textDocument/documentHighlight', { bufnr = event.buf }) then
        vim.keymap.set(nxo, opts.keymaps.next, jump({ forward = true }),
          { desc = 'Next reference', buffer = event.buf })

        vim.keymap.set(nxo, opts.keymaps.prev, jump({ forward = false }),
          { desc = 'Previous reference', buffer = event.buf })
        return
      end
    end
  })
end

return M

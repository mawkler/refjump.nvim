local M = {}

local function reference_jump(opts)
  opts = opts or { forward = true }

  local params = vim.lsp.util.make_position_params()
  local context = { includeDeclaration = true }
  params = vim.tbl_extend('error', params, { context = context })

  vim.lsp.buf_request(0, 'textDocument/references', params, function(err, references, _, _)
    if err then
      vim.notify('LSP Error: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    if not references or vim.tbl_isempty(references) then
      vim.notify('No references found', vim.log.levels.INFO)
      return
    end

    local current_position = vim.api.nvim_win_get_cursor(0)
    local current_line = current_position[1] - 1
    local current_col = current_position[2]

    local function find_reference()
      if opts.forward then
        return vim.iter(references):find(function(ref)
          local ref_pos = ref.range.start
          local ref_line = ref_pos.line
          local ref_col = ref_pos.character

          return ref_line > current_line or (ref_line == current_line and ref_col > current_col)
        end)
      else
        return vim.iter(references):rfind(function(ref)
          local ref_pos = ref.range.start
          local ref_line = ref_pos.line
          local ref_col = ref_pos.character

          return ref_line < current_line or (ref_line == current_line and ref_col < current_col)
        end)
      end
    end

    local next_reference = find_reference()

    -- If no reference is found in the chosen direction, loop around
    if not next_reference then
      next_reference = opts.forward and references[1] or references[#references]
    end

    if next_reference then
      local uri = next_reference.uri or next_reference.targetUri
      if not uri then
        vim.notify('Invalid URI in LSP response', vim.log.levels.ERROR)
        return
      end

      local bufnr = vim.uri_to_bufnr(uri)

      vim.fn.bufload(bufnr)
      vim.api.nvim_set_current_buf(bufnr)
      vim.api.nvim_win_set_cursor(0, {
        next_reference.range.start.line + 1,
        next_reference.range.start.character,
      })

      vim.cmd('normal! zv') -- Open folds if the reference is inside a fold
    else
      vim.notify('Could not find the next reference', vim.log.levels.WARN)
    end
  end)
end

function M.setup(_)
  vim.keymap.set('n', ']r', function() reference_jump({ forward = true }) end, {})
  vim.keymap.set('n', '[r', function() reference_jump({ forward = false }) end, {})
end

return M

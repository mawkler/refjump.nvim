local state = require('refjump.state')
local highlight = require('refjump.highlight')

describe('refjump.state', function()
  local bufnr

  before_each(function()
    -- Create a fresh buffer for each test
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(bufnr)
    -- Clear any existing state
    state.clear(bufnr)
  end)

  after_each(function()
    -- Clean up buffer
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  describe('get_reference_info', function()
    it('returns empty state initially', function()
      local info = state.get_reference_info(bufnr)
      assert.is_nil(info.index)
      assert.equals(0, info.total)
    end)

    it('returns correct info after set()', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
        { range = { start = { line = 5, character = 0 }, ['end'] = { line = 5, character = 5 } } },
        { range = { start = { line = 10, character = 0 }, ['end'] = { line = 10, character = 5 } } },
      }
      state.set(refs, 2, bufnr)

      local info = state.get_reference_info(bufnr)
      assert.equals(2, info.index)
      assert.equals(3, info.total)
    end)

    it('uses current buffer when bufnr not provided', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }
      state.set(refs, 1, bufnr)

      -- Should work without explicit bufnr since we set current buf in before_each
      local info = state.get_reference_info()
      assert.equals(1, info.index)
      assert.equals(1, info.total)
    end)
  end)

  describe('is_active', function()
    it('returns false initially', function()
      assert.is_false(state.is_active())
    end)

    it('returns true when highlights are enabled', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }
      -- Enable highlights to make is_active() return true
      highlight.enable(refs, bufnr)

      assert.is_true(state.is_active())

      -- Cleanup: disable highlights (need to call twice due to toggle behavior)
      highlight.disable()
      highlight.disable()
    end)

    it('returns false after highlights are disabled', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }
      highlight.enable(refs, bufnr)
      -- First disable flips flag to false
      highlight.disable()
      -- Second disable clears highlights
      highlight.disable()

      assert.is_false(state.is_active())
    end)
  end)

  describe('set', function()
    it('stores references and index', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
        { range = { start = { line = 5, character = 0 }, ['end'] = { line = 5, character = 5 } } },
      }
      state.set(refs, 1, bufnr)

      local info = state.get_reference_info(bufnr)
      assert.equals(1, info.index)
      assert.equals(2, info.total)
    end)

    it('handles nil references gracefully', function()
      state.set(nil, 1, bufnr)

      local info = state.get_reference_info(bufnr)
      assert.equals(1, info.index)
      assert.equals(0, info.total)
    end)
  end)

  describe('clear', function()
    it('clears state for buffer', function()
      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }
      state.set(refs, 1, bufnr)

      state.clear(bufnr)

      local info = state.get_reference_info(bufnr)
      assert.is_nil(info.index)
      assert.equals(0, info.total)
    end)
  end)

  describe('per-buffer isolation', function()
    it('maintains separate state for different buffers', function()
      local bufnr2 = vim.api.nvim_create_buf(false, true)

      local refs1 = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }
      local refs2 = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
        { range = { start = { line = 5, character = 0 }, ['end'] = { line = 5, character = 5 } } },
        { range = { start = { line = 10, character = 0 }, ['end'] = { line = 10, character = 5 } } },
      }

      state.set(refs1, 1, bufnr)
      state.set(refs2, 3, bufnr2)

      local info1 = state.get_reference_info(bufnr)
      local info2 = state.get_reference_info(bufnr2)

      assert.equals(1, info1.index)
      assert.equals(1, info1.total)
      assert.equals(3, info2.index)
      assert.equals(3, info2.total)

      -- Cleanup
      vim.api.nvim_buf_delete(bufnr2, { force = true })
    end)

    it('clearing one buffer does not affect others', function()
      local bufnr2 = vim.api.nvim_create_buf(false, true)

      local refs = {
        { range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 5 } } },
      }

      state.set(refs, 1, bufnr)
      state.set(refs, 1, bufnr2)

      state.clear(bufnr)

      -- State data for bufnr should be cleared
      local info1 = state.get_reference_info(bufnr)
      assert.is_nil(info1.index)
      assert.equals(0, info1.total)

      -- State data for bufnr2 should still exist
      local info2 = state.get_reference_info(bufnr2)
      assert.equals(1, info2.index)
      assert.equals(1, info2.total)

      -- Cleanup
      vim.api.nvim_buf_delete(bufnr2, { force = true })
    end)
  end)
end)

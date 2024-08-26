# Refjump

Jump to next/previous LSP reference in the current buffer for the item under the cursor with `]r`/`[r`.

If you have [demicolon.nvim](https://github.com/mawkler/demicolon.nvim) installed you can also repeat jumps with `;`/`,` . See the [Demicolon section](#demicolon) for more information.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'mawkler/refjump.nvim',
  -- keys = { ']r', '[r' }, -- Uncomment to lazy load
  opts = {}
}
```

## Configuration

The following is the default configuration:

```lua
opts = {
  keymaps = {
    enable = true,
    next = ']r', -- Keymap to jump to next LSP reference
    prev = '[r', -- Keymap to jump to previous LSP reference
  },
  highlights = {
    enable = true, -- Highlight the LSP references on jump
    auto_clear = true, -- Automatically clear highlights when cursor moves
  },
  integrations = {
    demicolon = {
      enable = true, -- Make `]r`/`[r` repeatable with `;`/`,` using demicolon.nvim
    },
  },
  verbose = true, -- Print message if no reference is found
}
```

## Integrations

### Demicolon

This plugin integrates with [demicolon.nvim](https://github.com/mawkler/demicolon.nvim). Demicolon lets you repeat `]r`/`[r` jumps with `;`/`,`. Refjump will cache the list of LSP references which gives you super responsive jump repetitions.

This integration is automatically set up if demicolon.nvim is detected and the option `integrations.demicolon.enable` is `true`.

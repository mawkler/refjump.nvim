# Refjump

Jump to next/previous LSP reference in the current buffer for the item under the cursor with `]r`/`[r`.

If you have [demicolon.nvim](https://github.com/mawkler/demicolon.nvim) installed you can also repeat jumps with `;`/`,`. See the [Demicolon section](#demicolon) for more information.

https://github.com/user-attachments/assets/7109c1bc-1664-46eb-b16a-fa65c4f05f74

## Installation

Refjump targets Neovim v0.11+. If you're on an older version, pin the commit [3459d17](https://github.com/mawkler/refjump.nvim/commit/3459d17ad750d49458fec5b315e3181c525c6b27) with your plugin manager.

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'mawkler/refjump.nvim',
  event = 'LspAttach', -- Uncomment to lazy load
  opts = {}
}
```

## Usage

- Press `]r` or `[r` to jump to the next/previous reference for the item under the cursor.
- Press `;`/`,` to keep jumping forward/backward between those references (requires [demicolon.nvim](https://github.com/mawkler/demicolon.nvim))

You can also prefix any jump with a count. For example, you can do `3]r` to jump to the third next reference. This also works for `;`/`,`.

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

### Highlights

Refjump highlights the references by default. It uses the highlight group `RefjumpReferences`. To change the highlight, see `:help nvim_set_hl()`.

## Integrations

### Demicolon

This plugin integrates with [demicolon.nvim](https://github.com/mawkler/demicolon.nvim). Demicolon lets you repeat `]r`/`[r` jumps with `;`/`,` (you can also still repeat `t`/`f`/`T`/`F` like you would expect). Refjump will cache the list of LSP references which gives you super responsive jump repetitions.

This integration is automatically set up if demicolon.nvim is detected and the option `integrations.demicolon.enable` is `true`.

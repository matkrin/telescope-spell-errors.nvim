# telescope-spell-errors.nvim

This is a [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
extension that lists all spelling mistakes in the current buffer using Neovim's
built-in spell-checking capabilities.

## Installation

#### lazy.nvim

```lua
require("lazy").setup({
    {
        "matkrin/telescope-spell-errors.nvim",
        config = function()
            require("telescope").load_extension("spell_errors")
        end,
        dependencies = "nvim-telescope/telescope.nvim",
    }
})
```

#### packer

```lua
use "matkrin/telescope-spell-errors.nvim"
```

#### vim-plug

```vim
Plug "matkrin/telescope-spell-errors.nvim",
```

After calling `require("telescope").setup()`:

```lua
require("telescope").load_extension("spell_errors")
```

## Configuration

Similar to `lsp_diagnostics`, the results show the type of the spelling mistake
(bad | rare | local | caps), its location (row:col) and the word itself. By
default these get highlighted according to the your color scheme's highlight
color (guisp of `SpellBad`, `SpellCap`, `SpellRare`, `SpellLocal`) You can
overwrite the these with the following highlight groups:

| Error type | Highlight group              |
| ---------- | ---------------------------- |
| bad        | `"TelescopeSpellErrorBad"`   |
| rare       | `"TelescopeSpellErrorRare"`  |
| local      | `"TelescopeSpellErrorLocal"` |
| caps       | `"TelescopeSpellErrorCap"`   |

> [!IMPORTANT] The highlight groups must be set _after_ loading the extension

<!--
```lua
require('telescope').setup {
    extensions = {
        spell_errors = {
        }
    }
}
```
-->

## Usage

Once installed, you can invoke the picker with the vim command:

```vim
:Telescope spell_errors
```

Or in Lua with:

```lua
require("telescope").extensions.spell_errors.spell_errors()
```

This will open a Telescope window showing all spelling errors in the current
buffer. Selecting an entry will move the cursor to the corresponding misspelled
word.

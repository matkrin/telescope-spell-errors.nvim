# telescope-spell-errors.nvim

## Installation

### lazy.nvim

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

## Configuration

Similar to `lsp_diagnostics`, the results show the type of the spelling mistake
(bad | rare | local | caps), its location (row:col) and the word itself.
According to the error type you can set the following highlight groups

| Error type | Highlight group              |
| ---------- | ---------------------------- |
| bad        | `"TelescopeSpellErrorBad"`   |
| rare       | `"TelescopeSpellErrorRare"`  |
| local      | `"TelescopeSpellErrorLocal"` |
| caps       | `"TelescopeSpellErrorCap"`   |

to get coloring of the the error type and the position.

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

Vim command:

```
:Telescope spell_errors
```

Lua:

```lua
require("telescope").extensions.spell_errors.spell_errors()
```

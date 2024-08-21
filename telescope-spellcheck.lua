local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

-- (`{[1]: string, [2]: 'bad'|'rare'|'local'|'caps', [3]: integer}[]`)

local function get_spell_errors()
    local filename = vim.api.nvim_buf_get_name(0)
    local lines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    local checked = {}
    for i, line in ipairs(lines) do
        local line_checked = vim.spell.check(line)
        if not vim.tbl_isempty(line_checked) then
            for _, spell_err in ipairs(line_checked) do
                table.insert(checked, {
                    filename = filename,
                    word = spell_err[1],
                    error_type = spell_err[2],
                    line_num = i,
                    col_num = spell_err[3],
                })
            end
        end
    end
    return checked
end

-- print(vim.inspect(get_spell_errors()))
-- print("OK")
local spell_bad = vim.api.nvim_get_hl(0, { name = "SpellBad" })
print(vim.inspect(spell_bad))
vim.api.nvim_set_hl(0, "TelescopeSpellCheckBad", { fg = spell_bad.sp })

-- our picker function: colors
local spellcheck = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Spellcheck",
        finder = finders.new_table {
            results = get_spell_errors(),
            entry_maker = function(entry)
                local pos = string.format("%4d:%2d", entry.line_num, entry.col_num)
                -- local spell_bad = vim.api.nvim_get_hl(0, {name = "SpellBad"})
                -- local spell_cap = vim.api.nvim_get_hl(0, {name = "SpellCap"})
                -- local spell_rare = vim.api.nvim_get_hl(0, {name = "SpellRare"})
                -- local spell_local = vim.api.nvim_get_hl(0, {name = "SpellLocal"})
                -- local spell_bad = vim.api.nvim_get_hl(0, { name = "SpellBad" })
                -- print(vim.inspect(spell_bad))
                -- vim.api.nvim_set_hl(0, "TelescopeSpellCheckBad", { fg = spell_bad.sp })
                return {
                    value = entry,
                    display = string.upper(entry.error_type) .. " " .. pos .. " ▏" .. entry.word,
                    ordinal = entry.word,
                    filename = entry.filename,
                    type = entry.error_type,
                    lnum = entry.line_num,
                    col = entry.col_num,
                }, { { 1, 4 }, "DiagnosticError" }
            end
        },
        previewer = conf.qflist_previewer(opts),
        sorter = conf.prefilter_sorter {
            tag = "type",
            sorter = conf.generic_sorter(opts),
        },
    }):find()
end

-- to execute the function
spellcheck()

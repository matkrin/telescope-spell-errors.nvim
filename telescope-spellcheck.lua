local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values


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

-- Highlight group names
local BAD = "TelescopeSpellCheckBad"
local RARE = "TelescopeSpellCheckRare"
local LOCAL = "TelescopeSpellCheckLocal"
local CAPS = "TelescopeSpellCheckCap"

local hl_map = {
    _bad = BAD,
    _rare = RARE,
    _local = LOCAL,
    _caps = CAPS,
}

-- Get highlight groups
local spell_bad = vim.api.nvim_get_hl(0, { name = "SpellBad" })
local spell_cap = vim.api.nvim_get_hl(0, { name = "SpellCap" })
local spell_rare = vim.api.nvim_get_hl(0, { name = "SpellRare" })
local spell_local = vim.api.nvim_get_hl(0, { name = "SpellLocal" })

-- Create hightlight groups (tokyonight uses undercurls, `sp` is the color)
vim.api.nvim_set_hl(0, BAD, { fg = spell_bad.sp })
vim.api.nvim_set_hl(0, CAPS, { fg = spell_cap.sp })
vim.api.nvim_set_hl(0, RARE, { fg = spell_rare.sp })
vim.api.nvim_set_hl(0, LOCAL, { fg = spell_local.sp })


local spellcheck = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Spellcheck",
        finder = finders.new_table {
            results = get_spell_errors(),
            entry_maker = function(entry)
                local pos = string.format("%4d:%3d", entry.line_num, entry.col_num)
                local type_and_pos = string.format("%-5s", string.upper(entry.error_type)) .. pos
                local highlight_len = string.len(type_and_pos)
                return {
                    value = entry,
                    display = function()
                        return type_and_pos .. "  ▏ " .. entry.word,
                            { { { 0, highlight_len }, hl_map["_" .. entry.error_type] } }
                    end,
                    ordinal = type_and_pos,
                    filename = entry.filename,
                    type = entry.error_type,
                    lnum = entry.line_num,
                    col = entry.col_num,
                }
            end
        },
        previewer = conf.qflist_previewer(opts),
        sorter = conf.prefilter_sorter {
            tag = "type",
            sorter = conf.generic_sorter(opts),
        },
    }):find()
end

spellcheck()

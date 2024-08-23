local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

--- return {row, col}, row 1-based, col 0-based
local function get_cursor_pos()
    return vim.api.nvim_win_get_cursor(0)
end

--- pos: {row, col}, row 1-based, col 0-based
local function set_cursor_position(pos)
    return vim.api.nvim_win_set_cursor(0, pos)
end

local function get_word_under_cursor()
    return vim.fn.expand("<cword>")
end

local function go_to_first_spell_error()
    -- vim.api.nvim_feedkeys("gg0]s", "n", true)
    -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("gg0]s", true, false, true), 'n', true)
    -- vim.api.nvim_input("gg0]s")
    vim.api.nvim_command("silent normal! gg0]s")
end

local function go_to_next_spell_error()
    -- vim.api.nvim_feedkeys("]s", "n", true)
    -- vim.api.nvim_input("]s")
    vim.api.nvim_command("silent normal! ]s")
end

local function get_spell_errors()
    local filename = vim.api.nvim_buf_get_name(0)
    local original_pos = get_cursor_pos()

    -- Move to the first spell error
    go_to_first_spell_error()

    -- Initialize spell errors table
    local spellerrors = {}

    local first_pos = get_cursor_pos()
    local word, error_type

    local pos = first_pos
    repeat
        word, error_type = unpack(vim.fn.spellbadword())
        table.insert(spellerrors, {
            filename = filename,
            word = word,
            error_type = error_type,
            line_num = pos[1],
            col_num = pos[2] + 1,
        })

        go_to_next_spell_error()
        pos = get_cursor_pos()

    until pos[1] == first_pos[1]

    set_cursor_position(original_pos)

    return spellerrors
end


-- local function get_spell_errors()
--     local filename = vim.api.nvim_buf_get_name(0)
--     local lines = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
--     local checked = {}
--     for i, line in ipairs(lines) do
--         local line_checked = vim.spell.check(line)
--         if not vim.tbl_isempty(line_checked) then
--             for _, spell_err in ipairs(line_checked) do
--                 table.insert(checked, {
--                     filename = filename,
--                     word = spell_err[1],
--                     error_type = spell_err[2],
--                     line_num = i,
--                     col_num = spell_err[3],
--                 })
--             end
--         end
--     end
--     return checked
-- end


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

    local picker = pickers.new(opts, {
        prompt_title = "Spellcheck",
        finder = finders.new_table {
            results = get_spell_errors(),
            entry_maker = function(entry)
                local pos = string.format("%4d:%3d", entry.line_num, entry.col_num)
                local type_and_pos = string.format("%-5s", string.upper(entry.error_type)) .. pos
                local highlight_len = string.len(type_and_pos)
                local highlight_group = hl_map["_" .. entry.error_type]
                local sep = "  ▏ "
                local dispaly_str = type_and_pos .. sep .. entry.word
                return {
                    value = entry,
                    display = function(_)
                        return dispaly_str, { { { 0, highlight_len }, highlight_group } }
                    end,
                    ordinal = dispaly_str,
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
    })

    picker:find()
end
spellcheck()

-- return require("telescope").register_extension {
--     setup = function(ext_config, config)
--         -- access extension config and user config
--     end,
--     exports = {
--         spellcheck = spellcheck
--     },
-- }

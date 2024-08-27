local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values


-- All with `_` as local is also a keyword
local hl_groups = {
    _bad = "TelescopeSpellErrorBad",
    _rare = "TelescopeSpellErrorRare",
    _local = "TelescopeSpellErrorLocal",
    _caps = "TelescopeSpellErrorCap",
}


--- Get the cursor position in the buffer
---@return integer[] { row, col } The current cursor position (row: 1-based, col: 0-based)
local function get_cursor_pos()
    return vim.api.nvim_win_get_cursor(0)
end

--- Set the cursor position in the buffer
---@param pos integer[] {row, col} (row 1-based, col 0-based)
local function set_cursor_position(pos)
    return vim.api.nvim_win_set_cursor(0, pos)
end

--- Jump to the first spell error
local function go_to_first_spell_error()
    -- Needs to be a synchronous call, so not `vim.api.nvim_feedkeys` or
    --  `vim.api.nvim_input` not possible,
    --  otherwise it ends up in the telescope prompt
    vim.api.nvim_command("silent normal! gg0]s")
end

--- Jump to the next spell error
local function go_to_next_spell_error()
    vim.api.nvim_command("silent normal! ]s")
end


-- Tried the approach of just checking each line with `vim.spell.check`,
--  but gave a lot more results that are not showing up in the buffer.
--  Also context would be missing

---@return table[] spellerrors
local function get_spell_errors()
    local filename = vim.api.nvim_buf_get_name(0)
    local original_pos = get_cursor_pos()

    go_to_first_spell_error()

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


local telescope_spell_errors = function(opts)
    if not vim.api.nvim_get_option_value("spell", {}) then
        vim.notify("Spell checking is not enabled in the current buffer.", vim.log.levels.WARN)
        return
    end

    opts = opts or {}

    local picker = pickers.new(opts, {
        prompt_title = "Spell Errors",
        finder = finders.new_table {
            results = get_spell_errors(),
            entry_maker = function(entry)
                local pos = string.format("%4d:%3d", entry.line_num, entry.col_num)
                local type_and_pos = string.format("%-5s", string.upper(entry.error_type)) .. pos
                local highlight_len = string.len(type_and_pos)
                local highlight_group = hl_groups["_" .. entry.error_type]
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


return require("telescope").register_extension {
    setup = function(ext_config, config)
        -- Get highlight groups
        local spell_bad = vim.api.nvim_get_hl(0, { name = "SpellBad" })
        local spell_cap = vim.api.nvim_get_hl(0, { name = "SpellCap" })
        local spell_rare = vim.api.nvim_get_hl(0, { name = "SpellRare" })
        local spell_local = vim.api.nvim_get_hl(0, { name = "SpellLocal" })

        -- Create hightlight groups (default, catppuccin, tokyonight use
        --  undercurls, `sp` is the color of the undercurl)
        vim.api.nvim_set_hl(0, hl_groups["_bad"], { fg = spell_bad.sp })
        vim.api.nvim_set_hl(0, hl_groups["_caps"], { fg = spell_cap.sp })
        vim.api.nvim_set_hl(0, hl_groups["_rare"], { fg = spell_rare.sp })
        vim.api.nvim_set_hl(0, hl_groups["_local"], { fg = spell_local.sp })
    end,
    exports = {
        spell_errors = telescope_spell_errors
    },
}

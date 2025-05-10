local state = require("floating-terminal.state")

local M = {}

M.ns_id = vim.api.nvim_create_namespace("floating_tabline")

vim.api.nvim_set_hl(0, "ActiveTab", { fg = "#e0ffff", bg = "#005f5f", bold = true })
vim.api.nvim_set_hl(0, "InactiveTab", { fg = "#aaaaaa", bg = "NONE" })

function M.update_terminal_title()
    local tab_count = #state.floating.tabs
    local title = string.format("Floating Terminal [%d/%d]", state.floating.current_tab, tab_count)
    vim.api.nvim_win_set_config(state.floating.main.win, { title = title })
end

function M.render_tabline()
    if not vim.api.nvim_win_is_valid(state.floating.tabline.win) then
        return
    end

    local tabline = ""
    local positions = {}

    for i, buf in ipairs(state.floating.tabs) do
        local active = (i == state.floating.current_tab)
        local current_title = string.format(active and " [%s] " or "  %s  ", buf.title)

        table.insert(positions, {
            start = #tabline,
            stop = #tabline + #current_title,
            active = (i == state.floating.current_tab),
        })
        tabline = tabline .. current_title
    end

    vim.api.nvim_buf_set_lines(state.floating.tabline.buf, 0, -1, false, { tabline })

    vim.api.nvim_buf_clear_namespace(state.floating.tabline.buf, M.ns_id, 0, -1)

    for _, pos in ipairs(positions) do
        local hl_group = pos.active and "ActiveTab" or "InactiveTab"
        vim.api.nvim_buf_set_extmark(state.floating.tabline.buf, M.ns_id, 0, pos.start, {
            end_col = pos.stop,
            hl_group = hl_group,
            hl_eol = false,
        })
    end
end

function M.next_tab()
    if #state.floating.tabs == 0 then
        return
    end
    state.floating.current_tab = (state.floating.current_tab % #state.floating.tabs) + 1
    vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab].buf)
    M.update_terminal_title()
    M.render_tabline()
end

function M.prev_tab()
    if #state.floating.tabs == 0 then
        return
    end
    state.floating.current_tab = (state.floating.current_tab - 2) % #state.floating.tabs + 1
    vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab].buf)
    M.update_terminal_title()
    M.render_tabline()
end

function M.new_tab()
    local buf = vim.api.nvim_create_buf(false, true)
    table.insert(state.floating.tabs, {
        buf = buf,
        title = "Tab " .. #state.floating.tabs + 1,
    })
    state.floating.current_tab = #state.floating.tabs
    vim.api.nvim_win_set_buf(state.floating.terminal.win, buf)
    vim.cmd.terminal()
    M.update_terminal_title()
    M.render_tabline()
end

function M.close_tab()
    if #state.floating.tabs == 0 then
        return
    end
    local buf_to_close = table.remove(state.floating.tabs, state.floating.current_tab).buf

    if #state.floating.tabs == 0 then
        vim.api.nvim_win_hide(state.floating.main.win)
    else
        state.floating.current_tab = math.min(state.floating.current_tab, #state.floating.tabs)
        vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab].buf)
        M.update_terminal_title()
        M.render_tabline()
    end
    vim.api.nvim_buf_delete(buf_to_close, { force = true })
end

function M.close_tabline()
    if not vim.api.nvim_buf_is_valid(state.floating.tabline.buf) then
        return
    end
    vim.api.nvim_win_close(state.floating.tabline.win, true)
    vim.api.nvim_buf_delete(state.floating.tabline.buf, { force = true })
    state.floating.tabline.buf = -1
    state.floating.tabline.win = -1
end

local function set_tab_title(tab_index)
    if not state.floating.tabs[tab_index] then
        return
    end

    -- Prevent multiple input windows
    if state.floating.title_change.win and vim.api.nvim_win_is_valid(state.floating.title_change.win) then
        return
    end

    -- Create a floating input window
    local input_buf = vim.api.nvim_create_buf(false, true)
    local width = 30
    local height = 1
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    state.floating.title_change.win = vim.api.nvim_open_win(input_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded",
        title = "Set Tab Title",
        title_pos = "center",
    })

    local augroup = vim.api.nvim_create_augroup("FloatingTerminalInput", { clear = true })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = augroup,
        pattern = tostring(state.floating.win),
        callback = function()
            if vim.api.nvim_win_is_valid(state.floating.title_change.win) then
                vim.api.nvim_win_close(state.floating.title_change.win, true)
                vim.api.nvim_buf_delete(input_buf, { force = true })
            end
            vim.api.nvim_del_augroup_by_id(augroup)
        end,
    })

    -- TODO: make these keymaps work in both normal and insert mode
    -- Set up keymaps for confirming or canceling the input
    vim.api.nvim_buf_set_keymap(input_buf, "i", "<CR>", "", {
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)
            local new_title = lines[1]
            if new_title == "" then
                new_title = "Tab " .. tab_index
            end
            state.floating.tabs[tab_index].title = new_title
            vim.api.nvim_win_close(state.floating.title_change.win, true)
            vim.api.nvim_buf_delete(input_buf, { force = true })
            state.floating.title_change.win = nil   -- Reset the active input window reference
            vim.api.nvim_del_augroup_by_id(augroup) -- Clear the autocommand group
            M.render_tabline()
        end,
        noremap = true,
        silent = true,
    })

    vim.api.nvim_buf_set_keymap(input_buf, "n", "<Esc>", "", {
        callback = function()
            vim.api.nvim_win_close(state.floating.title_change.win, true)
            vim.api.nvim_buf_delete(input_buf, { force = true })
            state.floating.title_change.win = nil   -- Reset the active input window reference
            vim.api.nvim_del_augroup_by_id(augroup) -- Clear the autocommand group
        end,
        noremap = true,
        silent = true,
    })

    -- vim.bo[input_buf].buftype = "prompt"
    vim.cmd.startinsert()
end

function M.set_current_tab_title()
    return set_tab_title(state.floating.current_tab)
end

return M

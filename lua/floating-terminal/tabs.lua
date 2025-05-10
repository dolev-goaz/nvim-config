local state = require("floating-terminal.state")

local M = {}

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
	for i, buf in ipairs(state.floating.tabs) do
		if i == state.floating.current_tab then
			tabline = tabline .. string.format(" [%s] ", buf.title)
		else
			tabline = tabline .. string.format("  %s  ", buf.title)
		end
	end

	vim.api.nvim_buf_set_lines(state.floating.tabline.buf, 0, -1, false, { tabline })
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


return M

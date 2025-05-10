local state = require("floating-terminal.state")
local tabs = require("floating-terminal.tabs")

local M = {}

function M.create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local parent_buf = vim.api.nvim_create_buf(false, true)
	local parent_win = vim.api.nvim_open_win(parent_buf, false, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = "Floating Terminal",
		title_pos = "center",
	})

	local tabline_buf = vim.api.nvim_create_buf(false, true)
	local tabline_win = vim.api.nvim_open_win(tabline_buf, false, {
		relative = "win",
		win = parent_win,
		width = width - 2,
		height = 1,
		col = 1,
		row = 0,
		style = "minimal",
		focusable = false,
	})

	local term_buf = opts.buf or vim.api.nvim_create_buf(false, true)
	local term_win = vim.api.nvim_open_win(term_buf, true, {
		relative = "win",
		win = parent_win,
		width = width - 2,
		height = height - 3,
		col = 1,
		row = 2,
		style = "minimal",
	})

	return {
		parent_buf = parent_buf,
		parent_win = parent_win,
		tabline_buf = tabline_buf,
		tabline_win = tabline_win,
		term_buf = term_buf,
		term_win = term_win,
	}
end

local function close_terminal_window()
	if vim.api.nvim_win_is_valid(state.floating.terminal.win) then
		vim.api.nvim_win_close(state.floating.terminal.win, true)
	end
end

local function close_terminal()
	if vim.api.nvim_win_is_valid(state.floating.main.win) then
		vim.api.nvim_win_hide(state.floating.main.win)
	end
end

function M.open_terminal()
	local current_tab = state.floating.tabs[state.floating.current_tab]
	local current_buf = nil
	if current_tab then
		current_buf = current_tab.buf
	end
	local created = M.create_floating_window({ buf = current_buf })
	state.floating.main.win = created.parent_win

	-- Ensure at least one terminal tab exists
	if not current_buf then
		state.floating.current_tab = 1
		table.insert(state.floating.tabs, {
			buf = created.term_buf,
			title = "Tab " .. state.floating.current_tab,
		})
	end

	if vim.bo[created.term_buf].buftype ~= "terminal" then
		vim.cmd.terminal()
	end
	state.floating.tabline.buf = created.tabline_buf
	state.floating.tabline.win = created.tabline_win
	state.floating.terminal.win = created.term_win
	tabs.update_terminal_title()
	tabs.render_tabline()

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(created.parent_win),
		callback = function()
			tabs.close_tabline()
			close_terminal_window()
			close_terminal()
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(created.term_win),
		callback = function()
			tabs.close_tabline()
			close_terminal_window()
			close_terminal()
		end,
	})
end

function M.toggle_terminal_open()
	if vim.api.nvim_win_is_valid(state.floating.main.win) then
		close_terminal()
		return
	end
	M.open_terminal()
end

return M

-- TODO: handle commands that close the terminal(like bye)
local render_tabline, close_tabline
local state = {
	floating = {
		main = {
			win = -1,
		},
		tabline = {
			buf = -1,
			win = -1,
		},
		terminal = {
			win = -1,
		},
		tabs = {}, -- Store buffers for each terminal tab
		current_tab = 1, -- Track the current active tab
		title_change = {
			win = -1,
		},
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	-- Calculate the position to center the parent container
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Create the parent container with a border
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

	-- Create the tabline window inside the parent container
	local tabline_buf = vim.api.nvim_create_buf(false, true)
	local tabline_win = vim.api.nvim_open_win(tabline_buf, false, {
		relative = "win",
		win = parent_win,
		width = width - 2, -- Adjust for border padding
		height = 1,
		col = 1,
		row = 1,
		style = "minimal",
		focusable = false,
	})

	-- Create the terminal window inside the parent container
	local term_buf = opts.buf or vim.api.nvim_create_buf(false, true)
	local term_win = vim.api.nvim_open_win(term_buf, true, {
		relative = "win",
		win = parent_win,
		width = width - 2, -- Adjust for border padding
		height = height - 3, -- Adjust for tabline and border
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

local function update_terminal_title()
	local tab_count = #state.floating.tabs
	local title = string.format("Floating Terminal [%d/%d]", state.floating.current_tab, tab_count)
	vim.api.nvim_win_set_config(state.floating.main.win, { title = title })
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

local function open_terminal()
	local current_tab = state.floating.tabs[state.floating.current_tab]
	local current_buf = nil
	if current_tab then
		current_buf = current_tab.buf
	end
	local created = create_floating_window({ buf = current_buf })
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
	update_terminal_title()
	render_tabline()

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(created.parent_win),
		callback = function()
			close_tabline()
			close_terminal_window()
			close_terminal()
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(created.term_win),
		callback = function()
			close_tabline()
			close_terminal_window()
			close_terminal()
		end,
	})
end

local function toggle_terminal_open()
	if vim.api.nvim_win_is_valid(state.floating.main.win) then
		close_terminal()
		return
	end
	open_terminal()
end

------- Tabs -------
local function next_tab()
	if #state.floating.tabs == 0 then
		return
	end
	state.floating.current_tab = (state.floating.current_tab % #state.floating.tabs) + 1
	vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab].buf)
	update_terminal_title()
	render_tabline()
end

local function prev_tab()
	if #state.floating.tabs == 0 then
		return
	end
	state.floating.current_tab = (state.floating.current_tab - 2) % #state.floating.tabs + 1
	vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab].buf)
	update_terminal_title()
	render_tabline()
end

local function close_tab()
	if #state.floating.tabs == 0 then
		return
	end
	local buf_to_close = table.remove(state.floating.tabs, state.floating.current_tab).buf

	if #state.floating.tabs == 0 then
		close_terminal()
	else
		state.floating.current_tab = math.min(state.floating.current_tab, #state.floating.tabs)
		vim.api.nvim_win_set_buf(state.floating.terminal.win, state.floating.tabs[state.floating.current_tab])
		update_terminal_title()
		render_tabline()
	end
	vim.api.nvim_buf_delete(buf_to_close, { force = true })
end

local function new_tab()
	local buf = vim.api.nvim_create_buf(false, true)
	table.insert(state.floating.tabs, {
		buf = buf,
		title = "Tab " .. #state.floating.tabs + 1,
	})
	state.floating.current_tab = #state.floating.tabs
	vim.api.nvim_win_set_buf(state.floating.terminal.win, buf)
	vim.cmd.terminal()
	update_terminal_title()
	render_tabline()
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
			state.floating.title_change.win = nil -- Reset the active input window reference
			vim.api.nvim_del_augroup_by_id(augroup) -- Clear the autocommand group
			render_tabline()
		end,
		noremap = true,
		silent = true,
	})

	vim.api.nvim_buf_set_keymap(input_buf, "n", "<Esc>", "", {
		callback = function()
			vim.api.nvim_win_close(state.floating.title_change.win, true)
			vim.api.nvim_buf_delete(input_buf, { force = true })
			state.floating.title_change.win = nil -- Reset the active input window reference
			vim.api.nvim_del_augroup_by_id(augroup) -- Clear the autocommand group
		end,
		noremap = true,
		silent = true,
	})

	-- vim.bo[input_buf].buftype = "prompt"
	vim.cmd.startinsert()
end

local function set_current_tab_title()
	return set_tab_title(state.floating.current_tab)
end

-- tab rendering

function render_tabline()
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

function close_tabline()
	if not vim.api.nvim_buf_is_valid(state.floating.tabline.buf) then
		return
	end
	vim.api.nvim_win_close(state.floating.tabline.win, true)
	vim.api.nvim_buf_delete(state.floating.tabline.buf, { force = true })
	state.floating.tabline.buf = -1
	state.floating.tabline.win = -1
end

------- Keymaps -------
local function set_terminal_keymaps(enable)
	if enable then
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-a>", new_tab, { desc = "Create new terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-n>", next_tab, { desc = "Next terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-p>", prev_tab, { desc = "Previous terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-w>", close_tab, { desc = "Close current terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-s>", set_current_tab_title, { desc = "Set current tab title" })
	else
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-a>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-n>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-p>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-w>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-s>")
	end
end

-- Update keymaps when toggling the terminal
local function toggle_terminal()
	local was_open = vim.api.nvim_win_is_valid(state.floating.main.win)
	toggle_terminal_open()
	set_terminal_keymaps(not was_open)
end
vim.keymap.set({ "n", "t", "i" }, "<C-t><C-t>", toggle_terminal, { desc = "Toggle floating terminal" })

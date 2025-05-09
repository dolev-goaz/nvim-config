-- TODO: handle commands that close the terminal(like bye)

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	-- Calculate the position to center the window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Create a buffer
	local buf = nil
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
	end

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal", -- No borders or extra UI elements
		border = "rounded",
		title = "Floating Terminal",
		title_pos = "center",
	})

	return { buf = buf, win = win }
end

local state = {
	floating = {
		win = -1,
		tabs = {}, -- Store buffers for each terminal tab
		current_tab = 1, -- Track the current active tab
	},
}

local function update_terminal_title()
	local tab_count = #state.floating.tabs
	local title = string.format("Floating Terminal [%d/%d]", state.floating.current_tab, tab_count)
	vim.api.nvim_win_set_config(state.floating.win, { title = title })
end

local function toggle_terminal_open()
	if vim.api.nvim_win_is_valid(state.floating.win) then
		vim.api.nvim_win_hide(state.floating.win)
		return
	end
	-- Create the floating window
	local current_buf = state.floating.tabs[state.floating.current_tab]
	local created = create_floating_window({ buf = current_buf })
	state.floating.win = created.win

	-- Ensure at least one terminal tab exists
	if not current_buf then
		table.insert(state.floating.tabs, created.buf)
		state.floating.current_tab = 1
	end

	if vim.bo[created.buf].buftype ~= "terminal" then
		vim.cmd.terminal()
	end
	-- vim.cmd.terminal()
	update_terminal_title()
end

local function next_tab()
	if #state.floating.tabs == 0 then
		return
	end
	state.floating.current_tab = (state.floating.current_tab % #state.floating.tabs) + 1
	vim.api.nvim_win_set_buf(state.floating.win, state.floating.tabs[state.floating.current_tab])
	update_terminal_title()
end

local function prev_tab()
	if #state.floating.tabs == 0 then
		return
	end
	state.floating.current_tab = (state.floating.current_tab - 2) % #state.floating.tabs + 1
	vim.api.nvim_win_set_buf(state.floating.win, state.floating.tabs[state.floating.current_tab])
	update_terminal_title()
end

local function close_tab()
	if #state.floating.tabs == 0 then
		return
	end
	local buf_to_close = table.remove(state.floating.tabs, state.floating.current_tab)

	if #state.floating.tabs == 0 then
		toggle_terminal_open() -- Close the terminal window if no tabs remain
	else
		state.floating.current_tab = math.min(state.floating.current_tab, #state.floating.tabs)
		vim.api.nvim_win_set_buf(state.floating.win, state.floating.tabs[state.floating.current_tab])
		update_terminal_title()
	end
	vim.api.nvim_buf_delete(buf_to_close, { force = true })
end

local function new_tab()
	local buf = vim.api.nvim_create_buf(false, true)
	table.insert(state.floating.tabs, buf)
	state.floating.current_tab = #state.floating.tabs
	vim.api.nvim_win_set_buf(state.floating.win, buf)
	vim.cmd.terminal()
	update_terminal_title()
end

local function set_terminal_keymaps(enable)
	if enable then
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-a>", new_tab, { desc = "Create new terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-n>", next_tab, { desc = "Next terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-p>", prev_tab, { desc = "Previous terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-w>", close_tab, { desc = "Close current terminal tab" })
	else
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-a>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-n>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-p>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-w>")
	end
end

-- Update keymaps when toggling the terminal
local function toggle_terminal()
	local was_open = vim.api.nvim_win_is_valid(state.floating.win)
	toggle_terminal_open()
	set_terminal_keymaps(not was_open)
end
vim.keymap.set({ "n", "t", "i" }, "<C-t><C-t>", toggle_terminal, { desc = "Toggle floating terminal" })

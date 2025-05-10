local state = require("floating-terminal.state")
local window = require("floating-terminal.window")
local keymaps = require("floating-terminal.keymaps")


local function toggle_terminal()
	local was_open = vim.api.nvim_win_is_valid(state.floating.main.win)
	window.toggle_terminal_open()
	keymaps.set_terminal_keymaps(not was_open)
end

vim.keymap.set({ "n", "t", "i" }, "<C-t><C-t>", toggle_terminal, { desc = "Toggle floating terminal" })

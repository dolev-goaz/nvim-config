local tabs = require("floating-terminal.tabs")

local M = {}

function M.set_terminal_keymaps(enable)
	if enable then
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-a>", tabs.new_tab, { desc = "Create new terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-n>", tabs.next_tab, { desc = "Next terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-p>", tabs.prev_tab, { desc = "Previous terminal tab" })
		vim.keymap.set({ "n", "t", "i" }, "<C-t><C-w>", tabs.close_tab, { desc = "Close current terminal tab" })
	else
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-a>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-n>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-p>")
		vim.keymap.del({ "n", "t", "i" }, "<C-t><C-w>")
	end
end

return M

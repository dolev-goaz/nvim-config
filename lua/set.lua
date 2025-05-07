vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.swapfile = false
vim.opt.backup = false
-- vim.opt.undodir = os.getenv("HOME").."/.vim/undodir"
-- vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 12

vim.opt.updatetime = 750

vim.opt.colorcolumn = "100"

---- terminal ----
-- exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>")

-- tab between terminals
vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")


---- clipboard ----
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y')


---- language ----
-- vim.opt.keymap = "hebrew"
vim.opt.termbidi = true -- if terminal supports
function ToggleHebrewEnglish()
	vim.cmd("set rightleft!")
	if vim.bo.keymap == "hebrew" then
		print("Toggled to english")
		vim.bo.keymap = ""
	else
		print("Toggled to hebrew")
		vim.bo.keymap = "hebrew"
	end
end

vim.api.nvim_set_keymap("n", "<leader>ll", ":lua ToggleHebrewEnglish()<CR>", { noremap = true, silent = true })

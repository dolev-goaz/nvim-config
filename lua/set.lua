vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

---- popup windows ----
vim.o.winborder = "rounded"

---- backup ----
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

---- Code Execution ----
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Execute current file" })
vim.keymap.set("n", "<space>x", ":.lua<CR>", { desc = "Execute current line" })
vim.keymap.set("v", "<space>x", ":lua<CR>", { desc = "Execute selected lines" })

---- terminal ----
-- exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>", { desc = "Exit terminal mode" })

-- tab between terminals
vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-N><C-w>h", { desc = "Tab left" })
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-N><C-w>j", { desc = "Tab down" })
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-N><C-w>k", { desc = "Tab up" })
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-N><C-w>l", { desc = "Tab right" })
vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "Tab left" })
vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "Tab down" })
vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "Tab up" })
vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "Tab right" })

-- scroll while centered
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })

-- dragging selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- paste without resetting buffer
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without resetting buffer" })

-- delete without resetting buffer
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without resetting buffer" })

-- replace current word in entire file
vim.keymap.set(
	"n",
	"<leader>r",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace hovered word in entire file" }
)

---- clipboard ----
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>Y", '"+Y', { desc = "Copy to system clipboard" })

-- highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

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

vim.api.nvim_set_keymap(
	"n",
	"<leader>ll",
	":lua ToggleHebrewEnglish()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Hebrew/English" }
)

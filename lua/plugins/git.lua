return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("gitsigns").setup({})
			vim.keymap.set("n", "<leader>ogp", ":Gitsigns preview_hunk<CR>", { desc = "[o]pen [g]it [p]review" })
			vim.keymap.set(
				"n",
				"<leader>tgb",
				":Gitsigns toggle_current_line_blame<CR>",
				{ desc = "[t]oggle [g]it [b]lame" }
			)
			vim.keymap.set("n", "<leader>ogl", ":Telescope git_commits<CR>", { desc = "[o]pen [g]it [l]ogs" })
			vim.keymap.set(
				"n",
				"<leader>oglb",
				":Telescope git_bcommits<CR>",
				{ desc = "[o]pen [g]it [l]ogs current [b]uffer" }
			)
			vim.keymap.set("n", "<leader>ogs", ":Telescope git_stash<CR>", { desc = "[o]pen [g]it [s]tash" })
		end,
	},
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},
}

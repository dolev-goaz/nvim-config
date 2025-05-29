return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{ "<leader>ogp", "<cmd>Gitsigns preview_hunk<CR>", desc = "[o]pen [g]it [p]review" },
			{ "<leader>tgb", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = "[t]oggle [g]it [b]lame" },
			{ "<leader>ogl", "<cmd>Telescope git_commits<CR>", desc = "[o]pen [g]it [l]ogs" },
			{ "<leader>oglb", "<cmd>Telescope git_bcommits<CR>", desc = "[o]pen [g]it [l]ogs current [b]uffer" },
			{ "<leader>ogs", "<cmd>Telescope git_stash<CR>", desc = "[o]pen [g]it [s]tash" },
		},
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 100,
			},
		},
	},
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},
}

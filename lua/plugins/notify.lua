return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		{
			"rcarriga/nvim-notify",
			config = function()
				require("notify").setup({
					merge_duplicates = true,
					max_width = 60,
					stages = "fade_in_slide_out",
					render = "wrapped-compact",
					background_colour = "FloatShadow",
					timeout = 3000,
				})
				vim.notify = require("notify")
			end,
		},
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			lsp = {
				hover = {
					enabled = false,
				},
			},
		})
	end,
}

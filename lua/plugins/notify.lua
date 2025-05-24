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
					render = "wrapped-default",
					background_colour = "FloatShadow",
					timeout = 3000,
					on_open = function(win)
						vim.api.nvim_win_set_config(win, {
							focusable = false,
						})
					end,
				})
				vim.notify = require("notify")
			end,
		},
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			views = {
				split = {
					enter = true,
					scrollbar = false,
				},
			},
			lsp = {
				hover = {
					enabled = false,
				},
			},
			messages = { enabled = true },
			routes = {
				-- Git status
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "Your branch" },
							{ find = "On branch" },
						},
					},
					view = "split",
				},
			},
		})
	end,
}

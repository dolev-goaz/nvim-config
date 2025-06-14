return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>o", group = "Open" },
			{ "<leader>og", group = "Open Git" },
			{ "<leader>t", group = "Toggle" },
			{ "<leader>tg", group = "Toggle Git" },
			{ "<leader>f", group = "Find" },
			{ "<leader>g", group = "Go To" },
			{ "<leader>l", group = "Language" },
			{ "<leader>c", group = "Code" },
			{ "<leader>cd", group = "Code Diagnostics" },
			{ "<leader>s", group = "Session" },
		})
	end,
}

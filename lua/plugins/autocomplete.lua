return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 150,
				},
				ghost_text = {
					enabled = false,
				},
			},
			signature = {
				enabled = true,
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
			-- NOTE: maybe check nvim-cmp for cmdline completion
		},
		opts_extend = { "sources.default" },
	},
	{
		-- Setup with :Copilot setup
		-- Get status with :Copilot status
		"github/copilot.vim",
		event = "InsertEnter",
	},
	{
		-- automatically pair ", (, etc
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	{
		-- automatically close and rename html tags
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
}

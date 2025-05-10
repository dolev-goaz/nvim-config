return {
	{
		"saghen/blink.cmp",
        event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
		version = "1.*",
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
					enabled = true,
				},
			},
			signature = {
				enabled = true,
				-- show_on_insert = true,
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
        -- Setup with :Copilot setup
        -- Get status with :Copilot status
		"github/copilot.vim",
	},
}

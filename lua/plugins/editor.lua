return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufReadPre",
		---@module "ibl"
		---@type ibl.config
		opts = {
			enabled = true,
			whitespace = {
				remove_blankline_trail = true,
			},
			scope = {
				enabled = false,
			},
		},
	},
	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		config = function()
			require("colorizer").setup({
				filetypes = { "*" },
				user_default_options = {
					css = true,
					-- Virtualtext character to use
					mode = "virtualtext",
					virtualtext_inline = "before",
				},
			})
		end,
	},
}

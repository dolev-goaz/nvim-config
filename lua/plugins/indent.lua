return {
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
}

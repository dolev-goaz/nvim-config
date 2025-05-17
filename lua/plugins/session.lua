return {
	"rmagatti/auto-session",
	event = "VeryLazy",
	keys = {
		{ "<leader>sf", ":SessionSearch<CR>", desc = "[s]ession [f]ind" },
		{ "<leader>sd", ":SessionDelete ", desc = "[s]ession [d]elete" },
		{ "<leader>sr", ":SessionRestore<CR>", desc = "[s]ession [r]estore" },
		{ "<leader>sc", ":SessionSave ", desc = "[s]ession [c]reate" },
	},
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		auto_create = false,
	},
}

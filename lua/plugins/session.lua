return {
	"rmagatti/auto-session",
	event = "VeryLazy",
	keys = {
		{ "<leader>sf", "<cmd>SessionSearch<CR>", desc = "[S]ession [F]ind" },
		{ "<leader>sd", "<cmd>SessionDelete<CR>", desc = "[S]ession [D]elete" },
		{ "<leader>sr", "<cmd>SessionRestore<CR>", desc = "[S]ession [R]estore" },
		{ "<leader>sc", ":SessionSave ", desc = "[S]ession [C]reate" },
	},
	---@module "auto-session"
	---@type AutoSession.Config
	opts = {
		auto_create = false,
	},
}

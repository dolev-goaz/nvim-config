local function ensure_ripgrep()
	local has_rg = vim.fn.executable("rg") == 1
	if has_rg then
		return
	end

	vim.notify("ripgrep not found. On linux, try:\nsudo apt install ripgrep")
end
ensure_ripgrep()

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {
			pickers = {
				live_grep = {
					file_ignore_patterns = {
						"node_modules",
						".git/",
						"dist",
					},
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
		},
		keys = {
			{ "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Telescope: Search Git files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[f]ind [f]iles" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "[f]ind [g]rep Search" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "[f]ind [h]elp" },
		},
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		event = "VeryLazy",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
	{
		"nvim-telescope/telescope-project.nvim",
		event = "VeryLazy",
		config = function()
			require("telescope").load_extension("project")
		end,
	},
}

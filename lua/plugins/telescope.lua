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
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope: Search Git files" })
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]iles" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[f]ind [g]rep Search" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[f]ind [h]elp" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
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
}

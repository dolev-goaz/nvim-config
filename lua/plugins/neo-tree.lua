-- NOTE: requires installing a font from https://www.nerdfonts.com/font-downloads
--       and configuring the terminal (if using fonts for file type)

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            filesystem = {
                hijack_netrw_behavior = "open_default"
            },
            window = {
                position = "right"
            }
        })
		vim.keymap.set("n", "<C-e>", ":Neotree filesystem toggle<CR>", { silent = true })
	end,
}

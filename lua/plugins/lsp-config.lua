return {
	{
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason").setup({})
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"vue_ls",
				},
				automatic_enable = false, -- prevent duplicate lsp setup
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			{
				"folke/lazydev.nvim",
				opts = {
					library = {
						{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					},
				},
			},
		},
		config = function()
			local lspconfig = require("lspconfig")
			local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
			local on_attach = require("nvim-navic").attach
			local telescope = require("telescope.builtin")

			-- lua lsp
			lspconfig["lua_ls"].setup({ capabilities = blink_capabilities, on_attach = on_attach })

			-- typescript+vue lsp
			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
			lspconfig["ts_ls"].setup({
				capabilities = blink_capabilities,
				on_attach = on_attach,
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = vue_language_server_path,
							languages = { "vue" },
						},
					},
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			})

			-- vue lsp
			lspconfig["volar"].setup({ capabilities = blink_capabilities, on_attach = on_attach })

			-- keymaps
			local function lsp_hover()
				vim.lsp.buf.hover({
					focusable = false,
					max_width = math.floor(vim.o.columns * 0.8),
					border = "rounded",
				})
			end
			vim.keymap.set("n", "K", lsp_hover, { desc = "Hover" })
			vim.keymap.set("n", "<leader>gd", telescope.lsp_definitions, { desc = "[g]o To [d]efinition" })
			vim.keymap.set("n", "<leader>gD", telescope.lsp_type_definitions, { desc = "[g]o To Type [D]efinition" })
			vim.keymap.set("n", "<leader>gi", telescope.lsp_implementations, { desc = "[g]o To [i]mplementation" })
			vim.keymap.set("n", "<leader>gr", telescope.lsp_references, { desc = "[g]o To [r]eferences" })

			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[c]ode [a]ctions" })
		end,
	},
}

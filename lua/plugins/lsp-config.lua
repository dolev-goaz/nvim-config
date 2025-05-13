return {
    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "ts_ls", "volar" },
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

            -- lua lsp
            lspconfig["lua_ls"].setup({ capabilities = blink_capabilities })

            -- typescript lsp
            local vue_language_server_path = vim.fn.stdpath("data")
                .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
            lspconfig["ts_ls"].setup({
                capabilities = blink_capabilities,
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
            lspconfig["volar"].setup({ capabilities = blink_capabilities })
            vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go To Definition" })
            vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { desc = "Go To Declaration" })
            vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go To Implementation" })
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Go To References" })

            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

            -- save on format
            -- TODO: add option to enable/disable autoformat
            local format_augroup = vim.api.nvim_create_augroup("LspFormat", { clear = true })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = format_augroup,
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end,
    },
}

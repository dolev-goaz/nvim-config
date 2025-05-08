return {
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({})
            vim.keymap.set("n", "<leader>ogp", ":Gitsigns preview_hunk<CR>", { desc = "Preview Git Hunk" })
            vim.keymap.set("n", "<leader>tgb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Git Blame" })
            vim.keymap.set("n", "<leader>ogl", ":Telescope git_commits<CR>", { desc = "Open Git Logs" })
            vim.keymap.set("n", "<leader>oglb", ":Telescope git_bcommits<CR>", { desc = "Open Git Logs in the current buffer" })
            vim.keymap.set("n", "<leader>ogs", ":Telescope git_stash<CR>", { desc = "Open Git Stash" })
        end,
    },
    {
        "tpope/vim-fugitive",
    }
}

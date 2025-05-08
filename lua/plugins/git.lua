return {
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({})
            -- Open Git Preview
            vim.keymap.set("n", "<leader>ogp", ":Gitsigns preview_hunk<CR>", { desc = "Preview Git Hunk" })
            -- Toggle Git Blame
            vim.keymap.set("n", "<leader>tgb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Toggle Git Blame" })
        end,
    },
}

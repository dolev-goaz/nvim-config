return {
    "smjonas/inc-rename.nvim",
    config = function()
        require("inc_rename").setup({
            preview_empty_name = true,
            show_message = true,
            save_in_cmdline_history = false
        })
        vim.keymap.set("n", "<leader>cr", ":IncRename ", { desc = "Rename Token" })
    end,
}

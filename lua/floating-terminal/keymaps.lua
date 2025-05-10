local tabs = require("floating-terminal.tabs")

local M = {}

function M.set_terminal_keymaps(enable)
    if enable then
        vim.keymap.set({ "n", "t", "i" }, "<C-t><C-n>", tabs.new_tab, { desc = "Create new terminal tab" })
        vim.keymap.set({ "n", "t", "i" }, "<C-t><C-l>", tabs.next_tab, { desc = "Next terminal tab" })
        vim.keymap.set({ "n", "t", "i" }, "<C-t><C-h>", tabs.prev_tab, { desc = "Previous terminal tab" })
        vim.keymap.set({ "n", "t", "i" }, "<C-t><C-w>", tabs.close_tab, { desc = "Close current terminal tab" })
        vim.keymap.set({ "n", "t", "i" }, "<C-t><C-s>", tabs.set_current_tab_title, { desc = "Set current tab title" })
    else
        vim.keymap.del({ "n", "t", "i" }, "<C-t><C-n>")
        vim.keymap.del({ "n", "t", "i" }, "<C-t><C-l>")
        vim.keymap.del({ "n", "t", "i" }, "<C-t><C-h>")
        vim.keymap.del({ "n", "t", "i" }, "<C-t><C-w>")
        vim.keymap.del({ "n", "t", "i" }, "<C-t><C-s>")
    end
end

return M

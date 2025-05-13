local function ensure_installed(package_name, installed_packages_names)
    for _, value in pairs(installed_packages_names) do
        if value == package_name then
            return true
        end
    end
    vim.notify(
        string.format("Package %s is not installed. Please install it using Mason.", package_name),
        vim.log.levels.WARN
    )
    return false
end

return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        local installed_packages = require("mason-registry").get_installed_package_names()
        local sources = {}

        -- NOTE: only install eslint_d version 13.1.2. In higher versions, it requires files
        -- with the format eslint.config.js.
        -- Install command: :MasonInstall eslint_d@13.1.2
        -- Sources:
        -- -- https://www.reddit.com/r/neovim/comments/1fdpap9/eslint_error_could_not_parse_linter_output_due_to/
        -- -- https://eslint.org/docs/latest/use/migrate-to-9.0.0
        if ensure_installed("eslint_d", installed_packages) then
            table.insert(sources, require("none-ls.diagnostics.eslint_d"))
        end
        if ensure_installed("prettier", installed_packages) then
            table.insert(sources, null_ls.builtins.formatting.prettier)
        end
        if ensure_installed("stylua", installed_packages) then
            table.insert(sources, null_ls.builtins.formatting.stylua)
        end
        null_ls.setup({ sources = sources })

        vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format current buffer" })
    end,
}

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

local null_ls_file_types = {
    -- file types supported by prettier
    "typescriptreact",
    "javascriptreact",
    "typescript",
    "javascript",
    "vue",
    "json",
    "css",
    "scss",
    "html",

    -- stylua
    "lua",
}
local function format_document()
    vim.lsp.buf.format({
        filter = function(client)
            local ft = vim.bo.filetype
            local use_null_ls = vim.tbl_contains(null_ls_file_types, ft)
            if use_null_ls then
                return client.name == "null-ls"
            end
            return true
        end,
    })
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

        -- formatting
        vim.keymap.set("n", "<leader>cf", format_document, { desc = "Format current buffer" })
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.ts", "*.js", "*.vue", "*.json", "*.css", "*.scss", "*.html", "*.lua" },
            callback = format_document,
        })
    end,
}

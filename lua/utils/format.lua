local M = {}

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
function M.format_document()
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

local autoformat_enabled = true

function M.toggle_autoformat()
	autoformat_enabled = not autoformat_enabled
	if autoformat_enabled then
		vim.notify("Autoformatting enabled", vim.log.levels.INFO)
	else
		vim.notify("Autoformatting disabled", vim.log.levels.INFO)
	end
end

-- Formatting
vim.keymap.set("n", "<leader>cf", M.format_document, { desc = "[c]ode [f]ormat" })
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.ts", "*.js", "*.vue", "*.json", "*.css", "*.scss", "*.html", "*.lua" },
	callback = function()
		if autoformat_enabled then
			M.format_document()
		end
	end,
})

vim.api.nvim_create_user_command("ToggleAutoformat", M.toggle_autoformat, { desc = "Toggle autoformatting on save" })

return M

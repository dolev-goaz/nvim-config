--- From: https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets
--- @param trunc_width number trunctates component when screen width is less then trunc_width
--- @param trunc_len number truncates component to trunc_len number of chars
--- @param hide_width number hides component when window width is smaller then hide_width
--- @param no_ellipsis boolean whether to disable adding '...' at end after truncation
--- @return function function that can format the component accordingly
local function trunc(trunc_width, trunc_len, hide_width, no_ellipsis)
	return function(str)
		local win_width = vim.o.columns
		if hide_width and win_width < hide_width then
			return ""
		elseif trunc_width and trunc_len and win_width < trunc_width and #str > trunc_len then
			return str:sub(1, trunc_len) .. (no_ellipsis and "" or "…")
		end
		return str
	end
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	enabled = vim.o.laststatus ~= 0,
	dependencies = {
		{
			"cameronr/lualine-pretty-path",
			-- dev = true,
		},
	},
	opts = function()
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local encoding_only_if_not_utf8 = function()
			local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
			return ret
		end
		local fileformat_only_if_not_unix = function()
			local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
			return ret
		end

		return {
			options = {
				theme = require("lualine.themes." .. vim.g.colors_name),
				section_separators = { left = "", right = "" },

				disabled_filetypes = { "alpha", "neo-tree" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = trunc(130, 3, 0, true),
						separator = { left = " ", right = "" },
					},
				},
				lualine_b = {
					{
						"branch",
						fmt = trunc(70, 15, 65, true),
					},
				},
				lualine_c = {
					{
						"pretty_path",
						directories = {
							max_depth = 4,
						},
						highlights = {
							newfile = "LazyProgressDone",
						},
						separator = "",
					},
					{
						function()
							return require("lualine-context").get_treesitter_context()
						end,
						icon = "󰅩",
					},
				},
				lualine_x = {
					{
						"diagnostics",
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						update_in_insert = true,
					},
					{
						"diff",
						symbols = {
							added = " ",
							modified = " ",
							removed = " ",
						},
						fmt = trunc(0, 0, 60, true),
					},
					{
						function()
							return "recording @" .. vim.fn.reg_recording()
						end,
						cond = function()
							return vim.fn.reg_recording() ~= ""
						end,
						color = { fg = "#ff007c" },
					},
					{

						function()
							local res = vim.fn.searchcount()
							if not res then
								return ""
							end
							local search_string = vim.fn.getreg("/")
							local base_format = search_string -- string.format('searching "%s"', search_string)
							if res["incomplete"] == 0 then
								return string.format("%s [%d/%d]", base_format, res["current"], res["total"])
							end
							if res["incomplete"] == 1 then
								return string.format(" [?/??]", base_format)
							end
							-- incomplete = 2, timeout
							-- if both current and total exceed maxcount
							if res["total"] > res["maxcount"] and res["current"] > res["maxcount"] then
								return string.format("%s [>%d/>%d]", base_format, res["current"], res["total"])
							else
								-- if only total exceeds maxcount
								if res["total"] > res["maxcount"] then
									return string.format("%s [%d/>%d]", base_format, res["current"], res["total"])
								end
							end
						end,
						icon = "",
						color = function()
							local res = vim.fn.searchcount()
							local is_empty = res["total"] == 0
							return { fg = is_empty and "#d08770" or "#ffffff" }
						end,
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						fmt = trunc(0, 0, 160, true),
						separator = "",
					},
					{
						encoding_only_if_not_utf8,
						fmt = trunc(0, 0, 140, true),
					},
					{
						fileformat_only_if_not_unix,
						fmt = trunc(0, 0, 140, true),
					},
				},
				lualine_y = {
					{
						function()
							return require("auto-session.lib").current_session_name(true)
						end,
						icon = "",
					},
				},
				lualine_z = {
					{
						"location",
						fmt = trunc(0, 0, 80, true),
						icon = "",
						separator = { left = "", right = " " },
					},
				},
			},
			inactive_sections = {
				lualine_c = {
					{
						"pretty_path",
					},
				},
			},
			extensions = {
				"lazy",
				"mason",
				"neo-tree",
				"quickfix",
			},
		}
	end,
}

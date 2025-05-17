local function reload_lazy()
	-- close Lazy and re-open when the dashboard is ready
	if vim.o.filetype == "lazy" then
		vim.cmd.close()
		vim.api.nvim_create_autocmd("User", {
			once = true,
			pattern = "AlphaReady",
			callback = function()
				require("lazy").show()
			end,
		})
	end
end

return {
	"goolord/alpha-nvim",
	priority = 2000,
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		{
			"nvim-telescope/telescope-project.nvim",
			dependencies = { "nvim-telescope/telescope.nvim" },
			config = function()
				require("telescope").load_extension("project")
			end,
		},
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local dashboard_utils = require("utils.dashboard")

		dashboard.section.header.val = dashboard_utils.headers.ghost
		dashboard.section.header.opts.hl = "DashboardHeader"

		dashboard.section.buttons.val = dashboard_utils.buttons

		local toggle_header
		local toggle_button
		local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
		if git_dir ~= "" then
			toggle_button = dashboard_utils.button("g", "  Toggle Git Header", function()
				toggle_header()
			end)
			table.insert(dashboard.section.buttons.val, 7, toggle_button)
		end

		dashboard.section.footer.val = dashboard_utils.generate_footer()
		dashboard.section.footer.opts.hl = "DashboardHeader"

		local greeting_section = dashboard_utils.create_text_section({ content = dashboard_utils.generate_greeting() })

		local plugin_stats_section = dashboard_utils.create_text_section({
			content = dashboard_utils.add_border_block(dashboard_utils.get_plugin_stats({ loading = true })),
			hl = "DashboardHeader",
		})

		local section = {
			header = dashboard.section.header,
			buttons = dashboard.section.buttons,
			greeting = greeting_section,
			plugins = plugin_stats_section,
			footer = dashboard.section.footer,
		}

		reload_lazy()

		local function get_vertical_align_padding()
			local total_content_height = dashboard_utils.get_section_text_height(section.header)
				+ 2 * dashboard_utils.get_section_text_height(section.buttons) -- buttons have one-line spacing
				+ dashboard_utils.get_section_text_height(section.greeting)
				+ 2 -- greeting + footer
				+ 4 -- spacing between sections
			local total_window_height = vim.fn.winheight(0) - 2 -- lualine and statusline
			return math.floor((total_window_height - total_content_height) / 2)
		end

		local opts = {
			layout = {
				{ type = "padding", val = get_vertical_align_padding() },
				section.header,
				{ type = "padding", val = 2 },
				section.buttons,
				section.plugins,
				{ type = "padding", val = 1 },
				section.greeting,
				{ type = "padding", val = 1 },
				section.footer,
			},
		}
		-- prevent autocmd sideeffects on initial load
		dashboard.opts.opts.noautocmd = true

		alpha.setup(opts)
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy", -- After lazy finished loading
			callback = function()
				section.plugins.val = dashboard_utils.add_border_block(dashboard_utils.get_plugin_stats())
				require("alpha").redraw()
			end,
		})

		toggle_header = function()
			local onefetch_active = dashboard_utils.toggle_header()
			opts.layout[1].val = get_vertical_align_padding()
			local icon = onefetch_active and "" or ""
			toggle_button.val = icon .. " Toggle Git Header "
			require("alpha").redraw()
		end
		-- TODO: allow opening dashboard with a command
	end,
}

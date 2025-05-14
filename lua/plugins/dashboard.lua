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

local function create_text_section(options)
    options = options or {}
    local section = {
        type = "text",
        val = options.content,
        opts = {
            position = "center",
            hl = options.hl,
        },
    }
    return section
end

local function get_greeting()
    local username = vim.fn.system("whoami"):gsub("%s+", "")
    return "Hi " .. username .. ", welcome back to Neovim!"
end

local function get_plugin_stats(options)
    options = options or {}
    if options.loading then
        return " Loading plugins..."
    end
    local stats = require("lazy").stats()
    local total_plugins = stats.count
    local total_loaded = stats.loaded
    local total_runtime = math.floor(stats.startuptime * 100 + 0.5) / 100

    return string.format(" Loaded %d/%d plugins in %d ms", total_loaded, total_plugins, total_runtime)
end

local function add_border(content)
    if type(content) == "function" then
        content = content()
    end
    if type(content) == "string" then
        content = { content }
    end
    local max_content_line_length = 0
    for _, line in ipairs(content) do
        local current_width = vim.fn.strdisplaywidth(line)
        if current_width > max_content_line_length then
            max_content_line_length = current_width
        end
    end
    local border = string.rep("─", max_content_line_length)

    table.insert(content, 1, border)
    table.insert(content, border)
    return content
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
        local function button(sc, txt, keybind, keybind_opts)
            local b = dashboard.button(sc, txt, keybind, keybind_opts)
            b.opts.hl_shortcut = "MiniIconsPurple"
            return b
        end

        dashboard.section.header.val = {
            [[                      ██████                     ]],
            [[                  ████▒▒▒▒▒▒████                 ]],
            [[                ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒██               ]],
            [[              ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██             ]],
            [[            ██▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒               ]],
            [[            ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▓▓▓▓           ]],
            [[            ██▒▒▒▒▒▒  ▒▒▓▓▒▒▒▒▒▒  ▒▒▓▓           ]],
            [[          ██▒▒▒▒▒▒▒▒▒▒    ▒▒▒▒▒▒▒▒    ██         ]],
            [[          ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██         ]],
            [[          ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██         ]],
            [[          ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██         ]],
            [[          ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██         ]],
            [[          ██▒▒██▒▒▒▒▒▒██▒▒▒▒▒▒▒▒██▒▒▒▒██         ]],
            [[          ████  ██▒▒██  ██▒▒▒▒██  ██▒▒██         ]],
            [[          ██      ██      ████      ████         ]],
            [[                                                 ]],
        }
        dashboard.section.header.opts.hl = "DashboardHeader"

        dashboard.section.buttons.val = {
            button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            button("f", "  Find Files", ":Telescope find_files <CR>"),
            button("p", "  Find project", "<cmd>lua require('telescope').extensions.project.project()<cr>"),
            button("r", "󰦛  Recent Files", "<cmd>Telescope oldfiles<cr>"),
            button("t", "  Find text", ":Telescope live_grep <CR>"),
            button("c", "  Neovim config", "<cmd>e ~/.config/nvim/ | cd %:p:h<cr>"),
            button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
            button("q", "󰅚  Quit NVIM", ":qa<CR>"),
        }

        local function footer()
            local footer_datetime = os.date(" %m-%d-%Y   %H:%M")
            local version = vim.version()
            local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch
            local value = footer_datetime .. nvim_version_info
            return value
        end

        dashboard.section.footer.val = footer()
        dashboard.section.footer.opts.hl = "DashboardHeader"

        local greeting_section = create_text_section({ content = get_greeting })

        local plugin_stats_section = create_text_section({
            content = add_border(get_plugin_stats({ loading = true })),
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

        local function get_section_text_height(current_section)
            local content = current_section.val
            if type(content) == "function" then
                content = content()
            end
            if type(content) == "string" then
                return 1
            end
            return #content
        end
        local function get_vertical_align_padding()
            local total_content_height = get_section_text_height(section.header)
                + 2 * get_section_text_height(section.buttons) -- buttons have one-line spacing
                + get_section_text_height(section.greeting)
                + 2                                            -- greeting + footer
                + 4                                            -- spacing between sections
            local total_window_height = vim.fn.winheight(0)
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
                section.plugins.val = add_border(get_plugin_stats())
                pcall(vim.cmd.AlphaRedraw) -- 🔄 refresh dashboard
            end,
        })

        -- TODO: allow opening dashboard with a command
    end,
}

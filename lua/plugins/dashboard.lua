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

        local greeting = function()
            local username = vim.fn.system("whoami"):gsub("%s+", "")
            return "Hi " .. username .. ", welcome back to Neovim!"
        end

        local greeting_section = {
            type = "text",
            val = greeting,
            opts = {
                position = "center",
            },
        }

        local section = {
            header = dashboard.section.header,
            buttons = dashboard.section.buttons,
            greeting = greeting_section,
            footer = dashboard.section.footer,
        }

        reload_lazy()

        local total_content_height = #section.header.val
            + 2 * #section.buttons.val -- buttons have one-line spacing
            + 2                        -- greeting + footer
            + 4                        -- spacing between sections
        local total_window_height = vim.fn.winheight(0)
        local vertical_align_padding = math.max(0, math.floor((total_window_height - total_content_height) / 2))

        local opts = {
            layout = {
                { type = "padding", val = vertical_align_padding },
                section.header,
                { type = "padding", val = 2 },
                section.buttons,
                { type = "padding", val = 1 },
                section.greeting,
                { type = "padding", val = 1 },
                section.footer,
            },
        }
        -- prevent autocmd sideeffects on initial load
        dashboard.opts.opts.noautocmd = true

        alpha.setup(opts)

        -- TODO: allow opening dashboard with a command
    end,
}

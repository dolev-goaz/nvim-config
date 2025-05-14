local M = {}

M.headers = {
    ghost = {
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
    },
}

function M.button(sc, txt, keybind, keybind_opts)
    local dashboard = require("alpha.themes.dashboard")
    local b = dashboard.button(sc, txt, keybind, keybind_opts)
    b.opts.hl_shortcut = "MiniIconsPurple"
    return b
end

M.buttons = {
    M.button("p", "  Find Project", "<cmd>lua require('telescope').extensions.project.project()<cr>"),
    M.button("e", "  New File", ":ene <BAR> startinsert <CR>"),
    M.button("f", "  Find Files", ":Telescope find_files <CR>"),
    M.button("r", "󰦛  Recent Files", "<cmd>Telescope oldfiles<cr>"),
    M.button("t", "  Find Text", ":Telescope live_grep <CR>"),
    M.button("c", "  Neovim Config", "<cmd>e ~/.config/nvim/ | cd %:p:h<cr>"),
    M.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
    M.button("q", "󰅚  Quit NVIM", ":qa<CR>"),
}

function M.generate_footer()
    local footer_datetime = os.date(" %m-%d-%Y   %H:%M")
    local version = vim.version()
    local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch
    local value = footer_datetime .. nvim_version_info
    return value
end

function M.create_text_section(options)
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

function M.generate_greeting()
    local username = os.getenv("USER")
    return "Hi " .. username .. ", welcome back to Neovim!"
end

function M.add_border_block(content)
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

function M.get_plugin_stats(options)
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

function M.get_section_text_height(current_section)
    local content = current_section.val
    if type(content) == "function" then
        content = content()
    end
    if type(content) == "string" then
        return 1
    end
    return #content
end

function M.toggle_header()
    local dashboard = require("alpha.themes.dashboard")
    if dashboard.section.header.val ~= M.headers.ghost then
        dashboard.section.header.val = M.headers.ghost
        return
    end

    local data = require("onefetch").get_onefetch()
    if data then
        dashboard.section.header.val = data
    else
        vim.notify("onefetch data not found", vim.log.levels.WARN, { title = "Dashboard" })
    end
end

return M

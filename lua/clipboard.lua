if vim.fn.has("wsl") then
    -- if running through WSL, use wind32yank to communicate with windows clipboard
	local clipboard_path = vim.fn.exepath("win32yank.exe")
	if clipboard_path == "" then
		vim.notify("win32yank.exe not found in PATH. Clipboard integration in WSL skipped.", vim.log.levels.WARN)
		return
	end
	vim.g.clipboard = {
		name = "wslclipboard",
		copy = {
			["+"] = clipboard_path .. " -i --crlf",
			["*"] = clipboard_path .. " -i --crlf",
		},
		paste = {
			["+"] = clipboard_path .. " -o --lf",
			["*"] = clipboard_path .. " -o --lf",
		},
		cache_enabled = 1,
	}
end

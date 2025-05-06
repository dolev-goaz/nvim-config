if vim.fn.has("wsl") then
	-- if ran on my main PC- use win32yank
	local clipboard_path = "/mnt/c/programdata/chocolatey/lib/win32yank/tools/win32yank.exe"
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

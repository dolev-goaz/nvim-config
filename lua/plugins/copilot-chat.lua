local is_copilot_open = false
local function toggle_copilot_chat()
	local copilot_chat = require("CopilotChat")
	if is_copilot_open then
		copilot_chat.close()
	else
		copilot_chat.open({
			context = { "buffer" },
		})
	end
	is_copilot_open = not is_copilot_open
end

return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken",
		config = function()
			require("CopilotChat").setup({})
			vim.keymap.set("n", "<C-c>", toggle_copilot_chat, { desc = "Toggle Copilot Chat" })
		end,
	},
}

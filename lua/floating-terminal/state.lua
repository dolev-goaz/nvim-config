-- Shared state for the floating terminal
local state = {
	floating = {
		main = { win = -1 },
		tabline = { buf = -1, win = -1 },
		terminal = { win = -1 },
		tabs = {}, -- Store buffers for each terminal tab
		current_tab = 1, -- Track the current active tab
		title_change = { win = -1 },
	},
}

return state

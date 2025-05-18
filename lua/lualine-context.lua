local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local function reverse_table(data)
	local reversed = {}
	for i = #data, 1, -1 do
		table.insert(reversed, data[i])
	end
	return reversed
end

local function is_node_type_interesting(type)
	return type == "function"
		or type == "function_declaration"
		or type == "method_definition"
		or type == "arrow_function"
		or type == "class_declaration"
		-- statements
		or type == "export_statement"
		or type == "for_statement"
		or type == "while_statement"
		or type == "if_statement"
end

function get_treesitter_context()
	local node = ts_utils.get_node_at_cursor()
	if not node then
		return "empty"
	end

	local context = {}

	while node do
		local type = node:type()
		if is_node_type_interesting(type) then
			local name_node = node:field("name")[1]
			if not name_node then
				if string.match(type, "_statement$") then
					local statement_name = type:gsub("_statement", "")
					table.insert(context, statement_name)
				end
			else
				local ok, text = pcall(vim.treesitter.get_node_text, name_node, 0)
				if ok then
					table.insert(context, text or type)
				end
			end
		end
		node = node:parent()
	end
	return table.concat(reverse_table(context), " > ")
end

return M

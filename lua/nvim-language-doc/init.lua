-- TODO: lifecycle del buffer? meaning, do i need to close/destroy the buffer after use?
-- expose the config and actually use it
-- add a panel like `sg` to enter a specific method/class without having to rely on cursor
local config = require("nvim-language-doc.config")

local M = {}

---Open help window on the right side
function M._open_help_window(cmd)
	local arg = vim.fn.expand("<cword>")
	local buffnr = vim.api.nvim_create_buf(true, true)

	local cmd_content = vim.fn.system(cmd .. arg)

	vim.api.nvim_buf_set_lines(buffnr, 0, -1, false, vim.split(cmd_content, "\n"))
	local win_id = vim.api.nvim_open_win(buffnr, true, {
		split = "right",
		win = 0,
		style = "minimal",
	})

	if win_id == 0 then
		error("Failed to open Help window")
	end
end

---return the command to view the docstring based on the LSP attached
---@return string?
function M._get_cmd_by_lsp()
	local lsps = vim.lsp.get_clients()
	local lsp_configured = config.get_default_config().default

	for _, lsp in ipairs(lsps) do
		local name = lsp.name
		local helper_cmd = lsp_configured[name]

		if helper_cmd then
			return helper_cmd
		end
	end
	print("Failed to find a helper command for the language you are using. Add it to the config.")
	return nil
end

function M.execute()
	local cmd = M._get_cmd_by_lsp()
	if cmd ~= nil then
		M._open_help_window(cmd)
	end
end

return M

-- TODO: lifecycle del buffer? meaning, do i need to close/destroy the buffer after use?
local config = require("nvim-language-doc.config")
local M = {}

---Open help window on the right side
function M.open_help_window(cmd)
	local arg = vim.fn.getreg('"')
	print(arg)
	print(cmd)
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
---@return string
function M.get_cmd_by_lsp()
	local lsps = vim.lsp.get_clients()
	local lsp_configured = config.get_default_config().default
	for _, lsp in ipairs(lsps) do
		local name = lsp.name
		local helper_cmd = lsp_configured[name]

		if helper_cmd then
			print(helper_cmd)
			return helper_cmd
		end
	end
	error("Failed to find a helper command for the language you are using. Add it to the config.")
end

-- local helper_cmd = get_cmd_by_lsp()
-- open_help_window(helper_cmd)
return M

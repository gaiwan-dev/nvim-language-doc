local M = {}

function M.get_default_config()
	return {
		default = {
			ruff = "python3 -m pydoc ",
			pyright = "python3 -m pydoc ",
			lua_ls = "python3 -m pydoc ",
		},
		settings = {},
	}
end

return M

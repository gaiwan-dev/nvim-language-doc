-- TODO: add a panel like `sg` to enter a specific method/class without having to rely on cursor
-- TODO: add python support for module.class like pathlib.Path
local default_config = require("nvim-language-doc.config")

local M = {}

---open docs window with the output of the command being executed
---@param cmd string
function M._open_help_window(cmd)
    local arg = vim.fn.expand("<cword>")
    local buffnr = vim.api.nvim_create_buf(true, true)

    local cmd_content = vim.fn.system(cmd .. " " .. arg)

    vim.api.nvim_buf_set_lines(
        buffnr,
        0,
        -1,
        false,
        vim.split(cmd_content, "\n")
    )
    local win_id = vim.api.nvim_open_win(buffnr, true, {
        split = M.config.window.position,
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
    local lsp_configured = M.config.lsp

    for _, lsp in ipairs(lsps) do
        local name = lsp.name
        local helper_cmd = lsp_configured[name]

        if helper_cmd then
            return helper_cmd
        end
    end
    print(
        "Failed to find a helper command for the language you are using. Add it to the config."
    )
    return nil
end

---merge the default config with the user config and set it in M
---@param custom_config table
function M.setup(custom_config)
    M.config =
        vim.tbl_extend("force", default_config.config, custom_config or {})
end

---current primary function that is used by the ShowDocs command exposed
function M.execute()
    local cmd = M._get_cmd_by_lsp()
    if cmd ~= nil then
        M._open_help_window(cmd)
    end
end

return M

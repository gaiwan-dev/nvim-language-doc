-- TODO: add a panel like `sg` to enter a specific method/class without having to rely on cursor
local default_config = require("nvim-language-doc.config")
local py_plugin = require("nvim-language-doc.languages.python")

local M = {}

---open docs window with the output of the command being executed
---@param cmd string
function M._open_help_window(cmd, arg)
    if arg == nil then
        arg = vim.fn.expand("<cword>")
    end
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

-- TODO: understand how the plugin system can be more dynamic. Example based on file type?
---primary function that is used by the ShowDocs command exposed
function M.execute()
    local cmd = M._get_cmd_by_lsp()
    if cmd ~= nil then
        local argument = py_plugin.extract_module()
        M._open_help_window(cmd, argument)
    end
end

return M

local M = {}
local ts_utils = require("nvim-treesitter.ts_utils")
local node_print = vim.treesitter.get_node_text

-- Helper function to search for the import node
---@param identifier string: name of the word currently selected
---@return string?: argument to send to pydoc or nil if not found
function M.find_import_node(identifier)
    local current_node = ts_utils.get_node_at_cursor()

    -- Walk up the tree to the module node
    while current_node do
        if current_node:type() == "module" then
            break
        end
        current_node = current_node:parent()
    end

    if not current_node then
        print("Module not found for %s", identifier)
        return nil
    end
    for i, _ in current_node:iter_children() do
        if
            i:type() == "import_from_statement"
            or i:type() == "import_statement"
        then
            -- Importing from a specific module
            if i:type() == "import_from_statement" then
                local module_name = nil

                for j, _ in i:iter_children() do
                    if j:type() == "dotted_name" and not module_name then
                        -- First dotted_name is always the module
                        module_name = node_print(j, 0)
                    elseif
                        (j:type() == "dotted_name" or j:type() == "identifier")
                        and node_print(j, 0) == identifier
                    then
                        return module_name .. "." .. node_print(j, 0)
                    end
                end
            elseif i:type() == "import_statement" then
                -- Standard import
                for j, _ in i:iter_children() do
                    if
                        j:type() == "dotted_name"
                        and node_print(j, 0) == identifier
                    then
                        return identifier
                    end
                end
            end
        end
    end
    return nil
end

---extract the module to run against pydoc
---@return string?
function M.extract_module()
    local node = ts_utils.get_node_at_cursor()
    if node:type() == "identifier" then
        local identifier = node_print(node, 0)
        local import = M.find_import_node(identifier)
        if import then
            return import
        end
        print("No associated import found for ", identifier)
    else
        print("Cursor is not on an identifier.")
    end
    return nil
end

return M

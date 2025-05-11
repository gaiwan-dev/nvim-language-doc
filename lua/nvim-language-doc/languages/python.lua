local M = {}
local ts_utils = require("nvim-treesitter.ts_utils")

-- Helper function to search for the import node
function M.find_import_node(identifier)
    local current_node = ts_utils.get_node_at_cursor()

    print(current_node)
    print("enter while")
    -- Walk up the tree to the module node
    while current_node do
        print(">> ", current_node)
        if current_node:type() == "module" then
            break
        end
        current_node = current_node:parent()
    end

    if not current_node then
        print("Module not found!")
        return nil
    end

    -- Traverse siblings to find the matching import statement
    local child = current_node:child(0)
    while child do
        if child:type() == "import_from_statement" then
            print(">>>> ", child)
            print(vim.inspect(child))
            print("~ ", vim.inspect(child:field("module_name")))
            for k, v in ipairs(child:field("module_name")) do
                print("~ ", k, v)
            end
            local module_name =
                vim.treesitter.get_node_text(child:field("module_name")[1], 0)
            local names = child:field("names")
            for _, name_node in ipairs(names) do
                local name_text = vim.treesitter.get_node_text(name_node, 0)
                if name_text == identifier then
                    return module_name, name_text
                end
            end
        end
        child = child:next_sibling()
        print("Sibling ", child)
    end
    return nil
end

-- Main function to display the module path

function M.something()
    local node = ts_utils.get_node_at_cursor()
    if node:type() == "identifier" then
        local identifier = vim.treesitter.get_node_text(node, 0)
        print(identifier)
        local module, name = M.find_import_node(identifier)
        if module then
            print(string.format("%s is imported from %s", name, module))
        else
            print("No associated import found!")
        end
    else
        print("Cursor is not on an identifier!")
    end
end

-- Create a Neovim command to trigger this
-- api.nvim_create_user_command('ShowModulePath', show_module_path, {})
return M

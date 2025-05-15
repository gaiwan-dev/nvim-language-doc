local M = {}
local ts_utils = require("nvim-treesitter.ts_utils")

function M.node_print(node)
    return vim.treesitter.get_node_text(node, 0)
end

function M.build_attribute_chain(node)
    local parts = {}

    while node and node:type() == "attribute" do
        local attr = node:field("attr")[1]
        if attr then
            table.insert(parts, 1, M.node_print(attr))
        end
        node = node:field("value")[1]
    end

    if node and node:type() == "identifier" then
        table.insert(parts, 1, M.node_print(node))
    end

    return table.concat(parts, ".")
end

-- Helper function to search for the import node
---@param identifier string: name of the word currently selected
---@return string?: argument to send to pydoc or nil if not found
function M.find_import_node(identifier)
    local raw_node = ts_utils.get_node_at_cursor()

    local id_chain = identifier
    do
        local prev = raw_node:prev_sibling()
        if prev and prev:type() == "." then
            local attr = raw_node
            while attr and attr:type() ~= "attribute" do
                attr = attr:parent()
            end
            if attr then
                id_chain = M.node_print(attr):gsub("[%(%)]", "")
            end
        end
    end

    local root = id_chain:match("^[^%.]+")

    local cur = raw_node
    while cur and cur:type() ~= "module" do
        cur = cur:parent()
    end
    if not cur then
        print("Module not found for", identifier)
        return nil
    end

    -- handle `from X import Y` (so Path → pathlib.Path)
    for child, _ in cur:iter_children() do
        if child:type() == "import_from_statement" then
            local module_name
            for sub, _ in child:iter_children() do
                if sub:type() == "dotted_name" and not module_name then
                    module_name = M.node_print(sub)
                elseif
                    (sub:type() == "identifier" or sub:type() == "dotted_name")
                    and M.node_print(sub) == root
                then
                    -- build X.Y(.rest)
                    local rest = id_chain:sub(#root + 2)
                    if rest == "" then
                        return module_name .. "." .. root
                    else
                        return module_name .. "." .. rest
                    end
                end
            end
        end
    end

    -- handle plain `import X` statements for one that defines our root
    for child, _ in cur:iter_children() do
        if child:type() == "import_statement" then
            for sub, _ in child:iter_children() do
                if sub:type() == "dotted_name" then
                    local module_name = M.node_print(sub)

                    if id_chain == module_name then
                        return module_name
                    end

                    local esc = module_name:gsub("%.", "%%.")
                    if
                        root == module_name
                        or module_name:match("^" .. root .. "%.")
                        or root:match("^" .. esc .. "%.")
                    then
                        return id_chain
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
    if not node or node:type() ~= "identifier" then
        print("Not on an identifier")
        return nil
    end

    local identifier = M.node_print(node)

    local parent = node:parent()
    if parent and parent:type() == "attribute" then
        local full_chain = M.build_attribute_chain(parent)

        if not full_chain:find(identifier, 1, true) then
            full_chain = identifier
        end

        local parts = vim.split(full_chain, ".", { plain = true })
        local root = parts[1]

        local import = M.find_import_node(root)
        if import then
            if import ~= root then
                parts[1] = import
            end
            return table.concat(parts, ".")
        end
    end

    local import = M.find_import_node(identifier)
    if import then
        return import
    end
    return vim.fn.expand("<cword>")
end

return M

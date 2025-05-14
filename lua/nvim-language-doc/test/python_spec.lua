local python = require("nvim-language-doc.languages.python")

local function vim_setup(lines)
    local bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(bufnr)

    vim.bo[bufnr].filetype = "python"

    vim.cmd("syntax enable")
    vim.cmd("filetype detect")
end

describe("extract correct module from code:", function()
    it("'import pathlib; pathlib.Path()' gets 'pathlib.Path'", function()
        local lines = {
            "import pathlib",
            "p = pathlib.Path(__file__)",
        }
        vim_setup(lines)
        vim.api.nvim_win_set_cursor(0, { 2, 15 })

        local result = python.extract_module()
        assert.are.equal("pathlib.Path", result)
    end)
    it(
        "'from pathlib import Path; Path(__file__)' gets 'pathlib.Path'",
        function()
            local lines = {
                "from pathlib import Path",
                "p = Path(__file__)",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 2, 4 })
            local result = python.extract_module()

            assert.are.equal("pathlib.Path", result)
        end
    )
    it("'import yaml; yaml.full_load()' gets 'yaml' cursor on yaml", function()
        local lines = {
            "import yaml",
            "yaml.full_load()",
        }
        vim_setup(lines)
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        local result = python.extract_module()

        assert.are.equal("yaml", result)
    end)
    it(
        "'import yaml; yaml.full_load()' gets 'yaml.full_load' cursor on full_load",
        function()
            local lines = {
                "import yaml",
                "yaml.full_load()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 2, 5 })
            local result = python.extract_module()

            assert.are.equal("yaml.full_load", result)
        end
    )
    it(
        "'import pathlib; pathlib.Path.cwd()' gets 'pathlib.Path.cwd' cursor on cwd",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path.cwd()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 2, 19 })
            local result = python.extract_module()

            assert.are.equal("pathlib.Path.cwd", result)
        end
    )
    it(
        "'import pathlib; pathlib.Path.cwd()' gets 'pathlib.Path' cursor on Path",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path.cwd()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 2, 13 })
            local result = python.extract_module()

            assert.are.equal("pathlib.Path", result)
        end
    )
    it(
        "'import pathlib; pathlib.Path.cwd()' gets 'pathlib' cursor on pathlib",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path.cwd()",
            }
            vim_setup(lines)

            vim.api.nvim_win_set_cursor(0, { 2, 5 })
            local result = python.extract_module()

            assert.are.equal("pathlib", result)
        end
    )
    it(
        "'import pathlib; pathlib.Path().cwd()' gets 'pathlib' cursor on pathlib",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path().cwd()",
            }
            vim_setup(lines)

            vim.api.nvim_win_set_cursor(0, { 2, 5 })
            local result = python.extract_module()

            assert.are.equal("pathlib", result)
        end
    )

    it(
        "'import pathlib; pathlib.Path().cwd()' gets 'pathlib.Path' cursor on Path",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path().cwd()",
            }
            vim_setup(lines)

            vim.api.nvim_win_set_cursor(0, { 2, 13 })
            local result = python.extract_module()

            assert.are.equal("pathlib.Path", result)
        end
    )
    it(
        "'import pathlib; pathlib.Path().cwd()' gets 'pathlib.Path.cwd' cursor on cwd",
        function()
            local lines = {
                "import pathlib",
                "a = pathlib.Path().cwd()",
            }
            vim_setup(lines)

            vim.api.nvim_win_set_cursor(0, { 2, 20 })
            local result = python.extract_module()

            assert.are.equal("pathlib.Path.cwd", result)
        end
    )
end)

describe("extract from import statement with code: ", function()
    it("'import pathlib' gets 'pathlib' cursor on 'pathlib'", function()
        local lines = {
            "import pathlib",
        }
        vim_setup(lines)
        vim.api.nvim_win_set_cursor(0, { 1, 8 })
        local result = python.extract_module()
        assert.are.equal("pathlib", result)
    end)
    it(
        "'from pathlib import Path' gets 'pathlib' cursor on 'pathlib'",
        function()
            local lines = {
                "from pathlib import Path",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 1, 8 })
            local result = python.extract_module()
            assert.are.equal("pathlib", result)
        end
    )
    it("'from pathlib import Path' gets 'Path' cursor on 'Path'", function()
        local lines = {
            "from pathlib import Path",
        }
        vim_setup(lines)
        vim.api.nvim_win_set_cursor(0, { 1, 21 })
        local result = python.extract_module()
        assert.are.equal("pathlib.Path", result)
    end)
end)

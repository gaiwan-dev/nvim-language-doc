-- TODO: need to also see how it behaves when imports are in parentesis

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

describe("extract from code when the import is not the first one: ", function()
    it(
        "'import yaml; import pathlib; pathlib.Path()' gets 'pathlib.Path' with cursor on 'Path'",
        function()
            local lines = {
                "import yaml",
                "import pathlib",
                "a = pathlib.Path()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 3, 13 })
            local results = python.extract_module()

            assert.are.equal("pathlib.Path", results)
        end
    )
    it(
        "'import yaml; import pathlib; pathlib.Path()' gets 'pathlib' with cursor on 'pathlib'",
        function()
            local lines = {
                "import yaml",
                "import pathlib",
                "a = pathlib.Path()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 3, 5 })
            local results = python.extract_module()

            assert.are.equal("pathlib", results)
        end
    )
    it(
        "'import yaml; from pathlib import Path; Path()' gets 'pathlib.Path' with cursor on 'Path'",
        function()
            local lines = {
                "import yaml",
                "from pathlib import Path",
                "a = Path()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 3, 5 })
            local results = python.extract_module()

            assert.are.equal("pathlib.Path", results)
        end
    )
    it(
        "'import yaml; import pathlib; pathlib.Path().cwd()' gets 'pathlib.Path.cwd' with cursor on 'cwd'",
        function()
            local lines = {
                "import yaml",
                "import pathlib",
                "a = pathlib.Path().cwd()",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 3, 21 })
            local results = python.extract_module()

            assert.are.equal("pathlib.Path.cwd", results)
        end
    )
    it(
        "'from typing import (Annotated, Optional)' gets 'typing.Optional' with cursor on 'Optional'",
        function()
            local lines = {
                "from typing import (",
                "    Union,",
                "    Optional,",
                ")",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 3, 7 })
            local results = python.extract_module()

            assert.are.equal("typing.Optional", results)
        end
    )
    it(
        "'from typing import (Annotated, Optional); TYPE = Optional[str]' gets 'typing.Optional' with cursor on 'Optional'",
        function()
            local lines = {
                "from typing import (",
                "    Union,",
                "    Optional,",
                ")",
                "TYPE = Optional[str]",
            }
            vim_setup(lines)
            vim.api.nvim_win_set_cursor(0, { 5, 9 })
            local results = python.extract_module()

            assert.are.equal("typing.Optional", results)
        end
    )
end)

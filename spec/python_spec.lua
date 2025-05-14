local python = require("nvim-language-doc.languages.python")

describe("extract_module", function()
    it(
        "extracts 'pathlib.Path' from 'import pathlib; pathlib.Path()'",
        function()
            local bufnr = vim.api.nvim_create_buf(false, true)

            local lines = {
                "import pathlib",
                "p = pathlib.Path(__file__)",
            }

            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.api.nvim_set_current_buf(bufnr)

            -- Ensure filetype is python so Treesitter parser works
            vim.bo[bufnr].filetype = "python"

            -- Wait for Treesitter parser to attach
            vim.cmd("syntax enable")
            vim.cmd("filetype detect")

            -- Manually move the cursor to the word 'Path'
            vim.api.nvim_win_set_cursor(0, { 2, 15 }) -- line 2, column 15 (zero-based column!)

            -- Run your plugin's function
            local result = python.extract_module()

            assert.are.equal("pathlib.Path", result)
        end
    )
end)

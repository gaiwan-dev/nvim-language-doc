local langdoc = require("nvim-language-doc")
local py = require("nvim-language-doc.languages.python")

vim.api.nvim_create_user_command("ShowDocs", function()
    langdoc.execute()
end, {})

vim.api.nvim_create_user_command("ShowPy", function()
    py.extract_module()
end, {})

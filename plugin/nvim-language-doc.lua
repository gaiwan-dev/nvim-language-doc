local langdoc = require("nvim-language-doc")
vim.api.nvim_create_user_command("ShowDocs", function()
	langdoc.execute()
end, {})

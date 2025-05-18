-- scripts/minimal_init.lua
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")

vim.cmd("filetype plugin indent on")
pcall(require, "plenary.busted")

-- Treesitter: grab the languages we need *synchronously*
local ok, ts = pcall(require, "nvim-treesitter.configs")
if ok then
    ts.setup({
        ensure_installed = { "python" }, -- add any languages your specs need
        sync_install = true, -- block until the parser is ready
        auto_install = false, -- don't hit the network again later
        highlight = { enable = false },
    })
end

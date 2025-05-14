-- Add the local plugin itself to the runtime path
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Add plenary (adjust if you're using lazy.nvim)
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")

-- Filetype detection for Treesitter parser to work
vim.cmd("filetype plugin indent on")

-- Setup Plenary's test harness
pcall(require, "plenary.busted")

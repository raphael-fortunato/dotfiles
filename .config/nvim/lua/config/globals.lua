vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = "/home/raphael/cache/nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.updatetime = 50
vim.opt.colorcolumn = "100"
vim.g.mapleader = " "

vim.opt.splitbelow = true
vim.opt.mouse = "a"

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.autowriteall = true
vim.opt.termguicolors = true

vim.g.completeopt = { "menuone", "noinsert", "noselect" }
vim.g.cpp_pattern = "*{cpp,c,h,hpp,idl,CPP}"
vim.g.python_host_program = vim.fn.expand("~/nvim/bin/python")
vim.g.python3_host_prog = vim.fn.expand("~/nvim/bin/python")

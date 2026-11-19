-- Loaded before lazy.nvim startup. LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Only what differs from LazyVim lives here.
local opt = vim.opt

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

opt.swapfile = false
opt.backup = false
opt.undodir = "/home/furtunator/.cache/nvim/undodir"
opt.undofile = true

opt.hlsearch = false
opt.scrolloff = 8
opt.colorcolumn = "100"
opt.autowriteall = true
opt.fileformats = "dos,unix"
opt.winborder = "rounded"

vim.g.python3_host_prog = vim.fn.expand("~/nvim/bin/python")

vim.filetype.add({ extension = { CPP = "cpp", H = "cpp" } })

-- source nvim
vim.keymap.set("n", "<leader>so", ":so ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "<leader><leader>s", ":so %<CR>")
-- set leader
vim.g.mapleader = " "
-- copy to clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- delete without register save
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- Move between panes
vim.keymap.set("n", "<C-J>", "<C-W><C-J>")
vim.keymap.set("n", "<C-K>", "<C-W><C-K>")
vim.keymap.set("n", "<C-L>", "<C-W><C-L>")
vim.keymap.set("n", "<C-H>", "<C-W><C-H>")

vim.keymap.set("n", "<Left>", ":vertical resize +5<CR>")
vim.keymap.set("n", "<Right>", ":vertical resize -5<CR>")
vim.keymap.set("n", "<Down>", ":resize +5<CR>")
vim.keymap.set("n", "<Up>", ":resize -5<CR>")

-- yank and visual like pasting and deleting
vim.keymap.set("n", "Y", "y$")
vim.keymap.set("n", "vv", "V")
vim.keymap.set("n", "V", "v$")

vim.keymap.set("n", ">q", ":cnext<CR>")
vim.keymap.set("n", "<q", ":cprev<CR>")
-- Open UndotreeShow
vim.keymap.set("n", "<leader>u", ":UndotreeShow<CR>")

-- Toggle Maximizer
vim.keymap.set("n", "<leader>m", ":MaximizerToggle<CR>")

vim.keymap.set("n", "<leader>gs", ":Git<CR>")

vim.keymap.set("n", "gb", require("GoBehave").goto_definition)
vim.keymap.set("n", "<leader>gr", require("GoBehave").get_references)

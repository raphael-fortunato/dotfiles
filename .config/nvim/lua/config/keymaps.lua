-- source nvim
vim.keymap.set("n", "<leader>so", ":so ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "<leader><leader>s", ":so %<CR>")
-- set leader
-- copy to clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- delete without register save
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

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

-- bufjumps
local opts = { silent = true, noremap = true }
vim.api.nvim_set_keymap("n", "<M-o>", ":lua require('bufjump').backward()<cr>", opts)
vim.api.nvim_set_keymap("n", "<M-i>", ":lua require('bufjump').forward()<cr>", opts)

-- harpoon
vim.keymap.set("n", "<leader>mh", require("harpoon.mark").add_file)
vim.keymap.set("n", "<leader>mm", require("harpoon.ui").toggle_quick_menu)
vim.keymap.set("n", "<A-h>", function()
	require("harpoon.ui").nav_file(1)
end)
vim.keymap.set("n", "<A-t>", function()
	require("harpoon.ui").nav_file(2)
end)
vim.keymap.set("n", "<A-n>", function()
	require("harpoon.ui").nav_file(3)
end)
vim.keymap.set("n", "<A-s>", function()
	require("harpoon.ui").nav_file(4)
end)
vim.keymap.set("n", "<A-j>", require("harpoon.ui").nav_next)
vim.keymap.set("n", "<A-k>", require("harpoon.ui").nav_prev)

--trouble
vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics<cr>", { silent = true, noremap = true })

--lsp saga
vim.keymap.set("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", opts)

--telescope
vim.keymap.set("n", "<leader>fp", require("telescope.builtin").find_files)
vim.keymap.set("n", "<leader>fs", require("telescope").extensions.live_grep_args.live_grep_args)
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
vim.keymap.set("n", "<leader>gc", require("telescope.builtin").git_branches)
vim.keymap.set("n", "<leader>gw", require("telescope").extensions.git_worktree.git_worktrees)
vim.keymap.set("n", "<leader>gm", require("telescope").extensions.git_worktree.create_git_worktree)
vim.keymap.set("n", "<leader>fw", require("telescope.builtin").grep_string)
vim.keymap.set("v", "<leader>fv", "\"zy<cmd>exec 'Telescope grep_string default_text=' . escape(@z, ' ')<cr>")

vim.keymap.set("n", "<leader>sh", require("telescope.builtin").search_history)
vim.keymap.set("n", "<leader>tr", require("telescope.builtin").resume)

-- Git changed files picker
vim.keymap.set("n", "<leader>gF", function() _G.telescope_git_changed() end)

vim.keymap.set("n", "<leader>n", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFile<CR>")

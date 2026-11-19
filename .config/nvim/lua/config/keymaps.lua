-- Loaded on VeryLazy, after LazyVim's keymaps. LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

map("n", "<Left>", "<cmd>vertical resize +5<cr>")
map("n", "<Right>", "<cmd>vertical resize -5<cr>")
map("n", "<Down>", "<cmd>resize +5<cr>")
map("n", "<Up>", "<cmd>resize -5<cr>")

map("n", "vv", "V")
map("n", "V", "v$")

map("n", ">q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "<q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })

-- tmux-aware window navigation (LazyVim maps these to plain <C-w>hjkl)
map("n", "<C-h>", function() require("tmux").move_left() end, { desc = "Go to left window/pane" })
map("n", "<C-j>", function() require("tmux").move_bottom() end, { desc = "Go to lower window/pane" })
map("n", "<C-k>", function() require("tmux").move_top() end, { desc = "Go to upper window/pane" })
map("n", "<C-l>", function() require("tmux").move_right() end, { desc = "Go to right window/pane" })

-- Snippet placeholders on Alt keys
map({ "i", "s" }, "<M-l>", function()
	if vim.snippet.active({ direction = 1 }) then
		vim.snippet.jump(1)
	end
end, { desc = "Snippet: next placeholder" })
map({ "i", "s" }, "<M-h>", function()
	if vim.snippet.active({ direction = -1 }) then
		vim.snippet.jump(-1)
	end
end, { desc = "Snippet: previous placeholder" })

map("n", "gp", "<cmd>Lspsaga peek_definition<cr>", { silent = true, desc = "Peek definition" })

vim.api.nvim_create_user_command("LspRestart", function()
	vim.cmd("lsp restart")
end, { desc = "Restart LSP clients (alias for :lsp restart)" })

map("n", "<leader>gc", function() Snacks.picker.git_branches() end, { desc = "Git branches" })

-- Files changed on this branch vs the default branch (or uncommitted changes)
map("n", "<leader>gF", function()
	local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error ~= 0 or not root or root == "" then
		vim.notify("Could not find git root", vim.log.levels.ERROR)
		return
	end
	local base = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")[1]
	base = base and base:gsub("^refs/remotes/origin/", "") or nil
	if not base or base == "" then
		vim.fn.system("git show-ref --verify --quiet refs/heads/main")
		base = vim.v.shell_error == 0 and "main" or "master"
	end
	local branch = vim.fn.systemlist("git branch --show-current")[1] or "HEAD"
	local files = vim.fn.systemlist(("git -C %s diff --name-only %s...%s"):format(vim.fn.shellescape(root), base, branch))
	if vim.v.shell_error ~= 0 or #files == 0 then
		files = vim.fn.systemlist(("git -C %s diff --name-only HEAD"):format(vim.fn.shellescape(root)))
	end
	local items = {}
	for _, f in ipairs(files) do
		local path = root .. "/" .. f
		if vim.fn.filereadable(path) == 1 then
			items[#items + 1] = { file = path, text = f }
		end
	end
	if #items == 0 then
		vim.notify("No changed files found in current branch", vim.log.levels.WARN)
		return
	end
	Snacks.picker({ title = ("Changed Files (%s)"):format(branch), items = items, format = "file" })
end, { desc = "Git changed files (branch)" })

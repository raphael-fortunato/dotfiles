-- Plugins LazyVim doesn't ship, plus small tweaks to ones it does.
return {
	-- AI: copilot completion comes from the ai.copilot extra (blink source)
	{
		"zbirenbaum/copilot.lua",
		opts = {
			panel = { enabled = false, auto_refresh = true },
			suggestion = { auto_trigger = true, hide_during_completion = true, debounce = 75 },
			filetypes = { help = false, gitcommit = true, gitrebase = false, ["."] = true },
			copilot_node_command = "node",
			server_opts_overrides = { trace = "off" },
		},
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		build = "make tiktoken",
		opts = {},
	},

	{ "folke/todo-comments.nvim", opts = { signs = false } },

	-- typst: use the tinymist on PATH (~/.local/bin) rather than a mason copy
	{
		"neovim/nvim-lspconfig",
		opts = { servers = { tinymist = { mason = false } } },
	},

	-- git
	{
		"ThePrimeagen/git-worktree.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"<leader>gw",
				function()
					require("telescope").load_extension("git_worktree")
					require("telescope").extensions.git_worktree.git_worktrees()
				end,
				desc = "Git worktrees",
			},
			{
				"<leader>gm",
				function()
					require("telescope").load_extension("git_worktree")
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
				desc = "Create git worktree",
			},
		},
	},
	"tpope/vim-fugitive",
	"ttibsi/pre-commit.nvim",
	"sindrets/diffview.nvim",

	-- harpoon v1
	{
		"ThePrimeagen/harpoon",
		branch = "master",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>mh", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
			{ "<leader>mm", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
			{ "<A-h>", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
			{ "<A-t>", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
			{ "<A-n>", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
			{ "<A-s>", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
		},
	},

	-- tmux pane navigation (<C-hjkl> set in config/keymaps.lua); its <A-hjkl>
	-- resize keys would clash with harpoon and LazyVim's <A-j>/<A-k>
	{
		"aserowy/tmux.nvim",
		opts = { resize = { enable_default_keybindings = false } },
	},

	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = {},
	},
	"tpope/vim-surround",
	{
		"kwkarlwang/bufjump.nvim",
		opts = {},
		keys = {
			{ "<M-o>", function() require("bufjump").backward() end, desc = "Previous buffer in jumplist" },
			{ "<M-i>", function() require("bufjump").forward() end, desc = "Next buffer in jumplist" },
		},
	},

	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "Oil",
		keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" } },
		opts = {
			default_file_explorer = false,
			view_options = { show_hidden = true },
			skip_confirm_for_simple_edits = true,
		},
	},

	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		keys = {
			{ "<leader>xo", "<cmd>copen<cr>", desc = "Open quickfix" },
			{ "<leader>xc", "<cmd>cclose<cr>", desc = "Close quickfix" },
		},
	},

	{
		"folke/edgy.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>ue", function() require("edgy").toggle() end, desc = "Toggle Edgy" },
		},
		opts = {
			animate = { enabled = false },
			left = {},
			bottom = {},
			right = {
				{
					ft = "copilot-chat",
					title = "Copilot Chat",
					filter = function(buf)
						local name = vim.api.nvim_buf_get_name(buf)
						local ft = vim.bo[buf].filetype
						return ft == "copilot-chat" or ft == "CopilotChat" or name:match("CopilotChat") ~= nil
					end,
					size = { width = 0.35 },
				},
				{ ft = "help", title = "Help", size = { width = 85 } },
			},
		},
	},
}

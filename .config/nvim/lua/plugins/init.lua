return {
	-- Unde tree
	"mbbill/undotree",

	-- Telescope
	{
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup({})
		end,
	},
	-- Colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
	},

	-- Copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	-- Formatters
	-- "raphael-fortunato/black-nvim",
	"ckipp01/stylua-nvim",
	"rhysd/vim-clang-format",
	-- Latex
	"lervag/vimtex",

	-- git plugins
	"tpope/vim-fugitive",
	"ttibsi/pre-commit.nvim",
	"sindrets/diffview.nvim",
	-- { -- Adds git related signs to the gutter, as well as utilities for managing changes
	-- 	"lewis6991/gitsigns.nvim",
	-- 	opts = {
	-- 		-- See `:help gitsigns.txt`
	-- 		signs = {
	-- 			add = { text = "+" },
	-- 			change = { text = "~" },
	-- 			delete = { text = "_" },
	-- 			topdelete = { text = "‾" },
	-- 			changedelete = { text = "~" },
	-- 		},
	-- 	},
	-- },
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },

	{ "ThePrimeagen/harpoon", dependencies = { { "nvim-lua/plenary.nvim" } } },
	-- ui component
	{ "MunifTanjim/nui.nvim", lazy = true },

	-- cursor highlighting
	"dominikduda/vim_current_word",

	-- maximizer
	"szw/vim-maximizer",
	{ "folke/neodev.nvim", opts = {} },

	-- Tmux integration
	{
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup()
		end,
	},
	{
		dir = vim.fn.expand("~/Documents/plugins/GoBehave.nvim"),
		config = function()
			require("GoBehave")
		end,
	},
	-- refactoring
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	},
	-- editting
	{ "tpope/vim-surround" },
	{
		"kwkarlwang/bufjump.nvim",
		config = function()
			require("bufjump").setup()
		end,
	},
}

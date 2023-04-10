vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	-- Unde tree
	use("mbbill/undotree")
	--Treesitter
	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
	use("nvim-treesitter/playground")
	use({ "nvim-treesitter/nvim-treesitter-context", requires = "nvim-treesitter/nvim-treesitter" })

	-- Telescope
	use({ "nvim-telescope/telescope.nvim", tag = "0.1.0", requires = { { "nvim-lua/plenary.nvim" } } })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", requires = "nvim-telescope/telescope.nvim" })

	-- Lsp Setup
	use({
		"neovim/nvim-lspconfig",
		requires = {
			-- LSP Support
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "tzachar/cmp-tabnine", run = "./install.sh" },
			{ "f3fora/cmp-spell" },
			{ vim.fn.expand("~/Documents/plugins/cmp-behave") },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})
	use({ "lvimuser/lsp-inlayhints.nvim" })
	use({ "lithammer/nvim-pylance" })
	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})
	use("jose-elias-alvarez/null-ls.nvim")
	use({
		"folke/trouble.nvim",
		requires = "nvim-tree/nvim-web-devicons",
		config = function()
			require("trouble").setup({})
		end,
	})

	-- Formatters
	use({
		"raphael-fortunato/black-nvim",
	})
	use("ckipp01/stylua-nvim")
	use("rhysd/vim-clang-format")

	-- git plugins
	use("ThePrimeagen/git-worktree.nvim")
	use("tpope/vim-fugitive")
	use("sindrets/diffview.nvim")
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})

	use({ "ThePrimeagen/harpoon", requires = { { "nvim-lua/plenary.nvim" } } })
	use("chentoast/marks.nvim")
	-- Task bar vim
	use({ "nvim-lualine/lualine.nvim", requires = { { "kyazdani42/nvim-web-devicons" } } })
	-- colorscheme
	use("luisiacc/gruvbox-baby", { run = "main" })
	use("rebelot/kanagawa.nvim")

	-- lua tree
	use({ "kyazdani42/nvim-tree.lua", requires = { { "kyazdani42/nvim-web-devicons" } } })

	-- Add indentation guides
	use("lukas-reineke/indent-blankline.nvim")

	-- cursor highlighting
	use("dominikduda/vim_current_word")

	-- dap debugger
	use("mfussenegger/nvim-dap")
	use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
	use({ "nvim-telescope/telescope-dap.nvim", requires = { "mfussenegger/nvim-dap" } })
	use({ "theHamsta/nvim-dap-virtual-text", requires = { "mfussenegger/nvim-dap" } })
	use({ "mfussenegger/nvim-dap-python", requires = { "mfussenegger/nvim-dap" } })
	-- maximizer
	use("szw/vim-maximizer")
	-- Neotest
	use({
		"nvim-neotest/neotest",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
		},
	})
	use({ "/home/raphael/Documents/plugins/neotest-python/", requires = {
		"nvim-neotest/neotest",
	} })
	use({ "alfaix/neotest-gtest" })
	-- Tmux integration
	use({
		"aserowy/tmux.nvim",
		config = function()
			require("tmux").setup()
		end,
	})
	use({
		vim.fn.expand("~/Documents/plugins/GoBehave.nvim"),
		config = function()
			require("GoBehave")
		end,
	})
	-- refactoring
	use({
		"ThePrimeagen/refactoring.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	})
	-- editting
	use({ "tpope/vim-surround" })
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	})
	use("numToStr/Comment.nvim")
end)

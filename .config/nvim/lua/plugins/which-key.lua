return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
	},
	config = function()
		local wk = require("which-key")
		
		-- Setup which-key
		wk.setup({
			plugins = {
				marks = true, -- shows a list of your marks on ' and `
				registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
				spelling = {
					enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
					suggestions = 20, -- how many suggestions should be shown in the list?
				},
				-- the presets plugin, adds help for a bunch of default keybindings in Neovim
				-- No actual key bindings are created
				presets = {
					operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
					motions = true, -- adds help for motions
					text_objects = true, -- help for text objects triggered after entering an operator
					windows = true, -- default bindings on <c-w>
					nav = true, -- misc bindings to work with windows
					z = true, -- bindings for folds, spelling and others prefixed with z
					g = true, -- bindings for prefixed with g
				},
			},
			-- add operators that will trigger motion and text object completion
			-- to enable all native operators, set the preset / operators plugin above
			operators = { gc = "Comments" },
			key_labels = {
				-- override the label used to display some keys. It doesn't effect WK in any other way.
				-- For example:
				-- ["<space>"] = "SPC",
				-- ["<cr>"] = "RET",
				-- ["<tab>"] = "TAB",
			},
			icons = {
				breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
				separator = "➜", -- symbol used between a key and it's label
				group = "+", -- symbol prepended to a group
			},
			popup_mappings = {
				scroll_down = "<c-d>", -- binding to scroll down inside the popup
				scroll_up = "<c-u>", -- binding to scroll up inside the popup
			},
			window = {
				border = "rounded", -- none, single, double, shadow
				position = "bottom", -- bottom, top
				margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
				padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
				winblend = 0,
			},
			layout = {
				height = { min = 4, max = 25 }, -- min and max height of the columns
				width = { min = 20, max = 50 }, -- min and max width of the columns
				spacing = 3, -- spacing between columns
				align = "left", -- align columns left, center or right
			},
			ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
			hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
			show_help = true, -- show help message on the command line when the popup is visible
			triggers = "auto", -- automatically setup triggers
			-- triggers = {"<leader>"} -- or specify a list manually
			triggers_blacklist = {
				-- list of mode / prefixes that should never be hooked by WhichKey
				-- this is mostly relevant for key maps that start with a native binding
				-- most people should not need to change this
				i = { "j", "k" },
				v = { "j", "k" },
			},
		})

		-- Register keymaps with descriptions
		wk.register({
			-- LSP related mappings
			g = {
				name = "Go to / LSP",
				d = "Go to definition",
				D = "Go to declaration", 
				r = "Go to references (Telescope)",
				i = "Go to implementation",
				s = "Switch source/header (Clangd)",
				p = "Peek definition (LSP Saga)",
			},
			K = "LSP Hover",
			
			-- Treesitter
			["<C-space>"] = "Increment selection",
			
			-- Window resizing
			["<Left>"] = "Vertical resize +5",
			["<Right>"] = "Vertical resize -5", 
			["<Down>"] = "Resize +5",
			["<Up>"] = "Resize -5",
			
			-- Yank improvements
			Y = "Yank to end of line",
			vv = "Visual line mode",
			V = "Visual to end of line",
			
			-- Quickfix navigation
			[">q"] = "Next quickfix",
			["<q"] = "Previous quickfix",
			
			-- Leader key mappings
			["<leader>"] = {
				-- Source/reload config
				["<leader>s"] = "Source current file",
				so = "Source nvim config",
				
				-- Clipboard operations
				y = "Copy to clipboard",
				Y = "Copy line to clipboard", 
				d = "Delete without saving to register",
				
				-- Utility toggles
				u = "Show UndoTree",
				m = "Toggle Maximizer",
				n = "Toggle NvimTree",
				e = "Find file in NvimTree",
				
				-- Git operations
				g = {
					name = "Git/LSP Actions",
					s = "Git status",
					c = "Git branches (Telescope)",
					w = "Git worktrees (Telescope)",
					m = "Create git worktree",
					F = "Find changed files in branch",
					-- LSP actions
					f = "Code action",
					t = "Run current file test",
					d = "Run test with debugger", 
					o = "Open test output",
				},
				
				-- Telescope find operations
				f = {
					name = "Find/Search",
					p = "Find files",
					s = "Live grep",
					b = "Find buffers",
					h = "Help tags",
					w = "Grep word under cursor",
					v = "Grep visual selection",
				},
				
				-- Search/history
				s = {
					name = "Search/Session",
					h = "Search history",
				},
				
				-- Telescope resume
				tr = "Telescope resume",
				
				-- Trouble diagnostics
				t = {
					name = "Tests/Trouble",
					t = "Toggle trouble diagnostics",
					-- Test related mappings
					n = "Run nearest test",
					s = "Toggle test summary", 
					p = "Toggle test output panel",
					w = "Toggle test watch",
				},
				
				-- Harpoon file marks
				m = {
					name = "Marks/Maximizer",
					h = "Add harpoon mark",
					m = "Harpoon quick menu",
				},
				
				-- LSP workspace actions
				w = {
					name = "Workspace",
					s = "Workspace symbols",
				},
				
				-- Diagnostics
				v = {
					name = "Diagnostics",
					d = "Open diagnostic float",
				},
				
				-- Rename
				r = {
					name = "Rename/Rust",
					n = "LSP rename",
					-- Rust-analyzer specific commands (only available in Rust files)
					r = "Reload Rust workspace",
					m = "Expand macro",
					j = "Join lines",
					s = "Structural search & replace",
					h = "View HIR",
					M = "View MIR", 
					c = "Open Cargo.toml",
					R = "Run single test/main",
					D = "Debug single test/main",
				},
				
				-- Diagnostics enable/disable
				d = {
					name = "Diagnostics/Delete",
					d = "Disable diagnostics",
					e = "Enable diagnostics",
				},
				
				-- Treesitter context
				u = {
					name = "UI/Utils",
					t = "Toggle Treesitter Context",
				},
			},
		})

		-- Register Alt key mappings
		wk.register({
			-- Buffer jumping
			["<M-o>"] = "Jump backward in buffer list",
			["<M-i>"] = "Jump forward in buffer list",
			
			-- Harpoon file navigation
			["<A-h>"] = "Harpoon file 1",
			["<A-t>"] = "Harpoon file 2", 
			["<A-n>"] = "Harpoon file 3",
			["<A-s>"] = "Harpoon file 4",
			["<A-j>"] = "Harpoon next file",
			["<A-k>"] = "Harpoon previous file",
		})

		-- Register single key mappings
		wk.register({
			-- Diagnostic navigation
			["<C-n>"] = "Next diagnostic",
			["<C-p>"] = "Previous diagnostic",
		})

		-- Register insert mode mappings
		wk.register({
			["gk"] = "Signature help",
		}, { mode = "i" })

		-- Register visual mode mappings  
		wk.register({
			["<leader>gf"] = "Code action",
			["<leader>y"] = "Copy to clipboard",
			["<leader>d"] = "Delete without register",
			["<leader>fv"] = "Grep visual selection",
			["<bs>"] = "Decrement selection (Treesitter)",
		}, { mode = "v" })

	end,
}

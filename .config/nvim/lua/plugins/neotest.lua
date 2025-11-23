return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-python",
		"alfaix/neotest-gtest",
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					runner = "unittest",
				}),
				require("neotest-gtest").setup({}),
			},
		})
		vim.keymap.set("n", "<leader>gt", ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>")
		vim.keymap.set("n", "<leader>gd", ":lua require('neotest').run.run({ strategy = 'dap' })<CR>")
		vim.keymap.set("n", "<leader>go", ":lua require('neotest').output.open({ enter = true })<CR>")
		vim.keymap.set("n", "<leader>tw", ":lua require('neotest').watch.toggle(vim.fn.expand('%'))<CR>")
		-- Behave-specific keymaps (using 't' prefix for test to avoid LSP conflicts)
		vim.keymap.set("n", "<leader>tn", ":lua require('neotest').run.run()<CR>", { desc = "Run nearest test" })
		vim.keymap.set(
			"n",
			"<leader>ts",
			":lua require('neotest').summary.toggle()<CR>",
			{ desc = "Toggle test summary" }
		)
		vim.keymap.set(
			"n",
			"<leader>tp",
			":lua require('neotest').output_panel.toggle()<CR>",
			{ desc = "Toggle test output panel" }
		)
	end,
}

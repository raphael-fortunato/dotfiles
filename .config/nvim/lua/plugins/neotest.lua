-- neotest comes from the test.core extra (keys under <leader>t)
return {
	"nvim-neotest/neotest",
	dependencies = { "nvim-neotest/neotest-python", "alfaix/neotest-gtest" },
	keys = {
		{ "<leader>tn", function() require("neotest").run.run() end, desc = "Run Nearest" },
		{ "<leader>tp", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
	},
	opts = function(_, opts)
		opts.adapters = opts.adapters or {}
		opts.adapters["neotest-python"] = { runner = "unittest" }
		table.insert(opts.adapters, require("neotest-gtest").setup({}))
	end,
}

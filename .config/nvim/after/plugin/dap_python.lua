require("dap-python").setup("/home/raphael/nvim/bin/python")
table.insert(require("dap").configurations.python, {
	type = "python",
	request = "launch",
	name = "My custom launch configuration",
	program = "python",
	args = { "-m", "milking" },
})

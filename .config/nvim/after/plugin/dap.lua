require("dap-python").setup("python")
local dap = require("dap")
dap.adapters.python = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy" },
}

dap.configurations.cucumber = {
	{
		type = "cucumber",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = "python",
	},
}

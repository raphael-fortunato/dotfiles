require("nvim-dap-virtual-text").setup()
require("dap-python").setup("python")
local dap = require("dap")

dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
dap.adapters.python = {
	type = "executable",
	command = "python",
	args = { "-m", "debugpy" },
}
dap.adapters.cppdbg = {
	type = "executable",
	command = "/home/raphael/builds/cpptools/debugAdapters/bin/OpenDebugAD7", -- adjust as needed, must be absolute path
	name = "cppdbg",
	id = "cppdbg",
}

dap.configurations.cpp = {
	{
		name = "Gtest: Run all tests",
		type = "cppdbg",
		request = "launch",
		program = function()
			return vim.fn.input(
				"Path to executable: ",
				"/home/raphael/work/canopendevs/mod/drivers/mod/acm100/test/build/test_full_stack/test_full_stack_acm100"
			)
		end,
		cwd = "/home/raphael/work/canopendevs/mod/drivers/mod/acm100/test/build/test_full_stack",
		stopOnEntry = false,
		args = {
			"--gtest_break_on_failure",
		},
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
			{
				description = "Enable pretty-printing for gdb",
				text = "-enable-pretty-printing",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGUSR1 (used by liblely)",
				text = "handle SIGUSR1 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGUSR2 (used by liblely)",
				text = "handle SIGUSR2 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGRTMIN (used by mocked master)",
				text = "handle SIG34 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGRTMIN+1 (used by mocked slave)",
				text = "handle SIG35 nostop noprint pass",
				ignoreFailures = true,
			},
		},
	},
	{
		name = "Gtest: Run nearest test",
		type = "cppdbg",
		request = "launch",
		program = function()
			return vim.fn.input(
				"Path to executable: ",
				"/home/raphael/work/canopendevs/mod/drivers/mod/acm100/test/build/test_full_stack/test_full_stack_acm100"
			)
		end,
		cwd = "/home/raphael/work/canopendevs/mod/drivers/mod/acm100/test/build/test_full_stack",
		stopOnEntry = false,
		args = {
			"--gtest_break_on_failure",
			function()
				local line = vim.api.nvim_get_current_line()
				local parsed_line = vim.fn.split(line:match("%((.-)%)"), ",")
				print(vim.inspect(parsed_line))
				return vim.fn.input(
					"argument: ",
					"--gtest_filter=" .. '"' .. parsed_line[1] .. "." .. parsed_line[2] .. '"'
				)
			end,
		},
		setupCommands = {
			{
				text = "-enable-pretty-printing",
				description = "enable pretty printing",
				ignoreFailures = false,
			},
			{
				description = "Enable pretty-printing for gdb",
				text = "-enable-pretty-printing",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGUSR1 (used by liblely)",
				text = "handle SIGUSR1 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGUSR2 (used by liblely)",
				text = "handle SIGUSR2 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGRTMIN (used by mocked master)",
				text = "handle SIG34 nostop noprint pass",
				ignoreFailures = true,
			},
			{
				description = "ignore SIGRTMIN+1 (used by mocked slave)",
				text = "handle SIG35 nostop noprint pass",
				ignoreFailures = true,
			},
		},
	},
}

-- If you want to use this for Rust and C, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.cucumber = {
	{
		type = "python",
		request = "launch",
		name = "Behave unit test: Debug nearest",
		module = "behave",
		console = "internalConsole",
		args = {
			function()
				return vim.fn.expand("%:p") .. ":" .. vim.api.nvim__buf_stats(0).current_lnum
			end,
			"--no-skipped",
		},
		pythonPath = "python",
	},
}

dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Python: simplicity node",
		program = "/home/raphael/work/simplicity/test/mocks/mocks/module_patch/module_patch.py",
		console = "integratedTerminal",
		args = {
			function()
				return vim.split(vim.fn.expand("%"), "/")[2] .. ":" .. "main"
			end,
		},
		pythonPath = "python",
	},
}
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F6>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F7>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F8>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set(
	"n",
	"<leader>lp",
	":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point messages: '))<CR>"
)
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")

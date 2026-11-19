-- nvim-dap/dap-ui come from the dap.core extra; this adds your adapters,
-- configurations, dap-ui layout and F-keys. LazyVim's <leader>d* keys apply.
local gdb_setup = {
	{ text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = false },
	{ description = "Enable pretty-printing for gdb", text = "-enable-pretty-printing", ignoreFailures = true },
	{ description = "ignore SIGUSR1 (used by liblely)", text = "handle SIGUSR1 nostop noprint pass", ignoreFailures = true },
	{ description = "ignore SIGUSR2 (used by liblely)", text = "handle SIGUSR2 nostop noprint pass", ignoreFailures = true },
	{ description = "ignore SIGRTMIN (used by mocked master)", text = "handle SIG34 nostop noprint pass", ignoreFailures = true },
	{ description = "ignore SIGRTMIN+1 (used by mocked slave)", text = "handle SIG35 nostop noprint pass", ignoreFailures = true },
}

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "jbyuki/one-small-step-for-vimkind" },
		keys = {
			{
				"<F4>",
				function()
					-- (Re-)reads launch.json if present
					if vim.fn.filereadable(".vscode/launch.json") == 1 then
						require("dap.ext.vscode").load_launchjs(nil, { cpptools = { "c", "cpp" } })
					end
					require("dap").continue()
				end,
				desc = "DAP Continue",
			},
			{ "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
			{ "<F6>", function() require("dap").step_over() end, desc = "DAP Step over" },
			{ "<F7>", function() require("dap").step_into() end, desc = "DAP Step into" },
			{ "<F8>", function() require("dap").continue() end, desc = "DAP Continue" },
			{ "<F10>", function() require("osv").launch({ port = 8086 }) end, desc = "Launch Lua debug server" },
		},
		opts = function()
			local dap = require("dap")
			dap.set_log_level("TRACE")
			dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

			dap.adapters.cppdbg = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/OpenDebugAD7",
				name = "cppdbg",
				id = "cppdbg",
			}
			dap.adapters.codelldb = {
				type = "executable",
				command = "/usr/bin/codelldb",
				name = "codelldb",
				id = "code-lldb",
			}
			dap.adapters.nlua = function(callback, config)
				callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
			end

			dap.configurations.cpp = {
				{
					name = "Gtest: Run all tests",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input(
							"Path to executable: ",
							"/home/raphael/work/canopendevs/mod/drivers/mod/astronaut_powerbox/test/build/test_full_stack/test_full_stack_powerbox"
						)
					end,
					cwd = function()
						return vim.fn.input(
							"Test directory: ",
							"/home/raphael/work/canopendevs/mod/drivers/mod/astronaut_powerbox/test/build/test_full_stack"
						)
					end,
					stopOnEntry = false,
					args = { "--gtest_break_on_failure" },
					setupCommands = gdb_setup,
				},
				{
					name = "Gtest: Run nearest test",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ")
					end,
					cwd = function()
						return vim.fn.input("Path to cwd: ", vim.fn.expand("%:p:h"))
					end,
					stopOnEntry = false,
					args = {
						"--gtest_break_on_failure",
						function()
							local line = vim.api.nvim_get_current_line()
							local parsed = vim.fn.split(line:match("%((.-)%)"):gsub("%s", ""), ",")
							return vim.fn.input("argument: ", '--gtest_filter="' .. parsed[1] .. "." .. parsed[2] .. '"')
						end,
					},
					setupCommands = gdb_setup,
				},
			}
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
					subProcess = true,
				},
				{
					type = "python",
					request = "launch",
					name = "Behave Component test: Debug nearest",
					program = "/home/raphael/work/simplicity/test/mocks/mocks/module_patch/module_patch.py",
					console = "integratedTerminal",
					args = {
						function()
							return vim.split(vim.fn.expand("%"), "/")[2] .. ":" .. "main"
						end,
					},
					preLaunchTask = function()
						return "behave "
							.. vim.fn.expand("%:p")
							.. ":"
							.. vim.api.nvim__buf_stats(0).current_lnum
							.. "--no-skipped"
					end,
					pythonPath = "python",
				},
				{
					type = "python",
					request = "launch",
					name = "Behave unit test: Debug file",
					module = "behave",
					console = "internalConsole",
					args = {
						function()
							return vim.fn.expand("%:p")
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
				{
					type = "python",
					request = "launch",
					name = "Python: system test node",
					program = "/home/raphael/work/simplicity/test//system_tests/run_tests.py",
					console = "integratedTerminal",
					args = { "--tester-type", "BUILD_SERVER", "--tags=@raph", "--stop" },
					pythonPath = "python",
				},
				{
					type = "python",
					request = "launch",
					name = "Main",
					program = function()
						return vim.fn.expand("%:p")
					end,
					console = "integratedTerminal",
					args = { "-c", "utrecht", "-p", "2500", "-s", "50" },
					pythonPath = "python",
				},
				{
					type = "python",
					request = "launch",
					name = "Python unittest",
					module = "unittest",
					console = "integratedTerminal",
					args = {
						"discover",
						"-s",
						function()
							return vim.fn.expand("%:h")
						end,
					},
					pythonPath = "python",
				},
			}

			dap.configurations.javascript = {
				{
					type = "firefox",
					request = "launch",
					name = "Launch Edge against localhost",
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}",
				},
			}
			dap.configurations.typescript = dap.configurations.javascript

			dap.configurations.lua = {
				{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
			}
		end,
	},
	{
		"rcarriga/nvim-dap-ui",
		opts = {
			mappings = {
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				edit = "e",
				repl = "r",
				toggle = "t",
			},
			layouts = {
				{
					elements = { { id = "scopes", size = 0.25 }, "breakpoints", "stacks", "watches" },
					size = 40,
					position = "left",
				},
				{ elements = { "repl", "console" }, size = 0.25, position = "bottom" },
			},
			floating = { border = "single", mappings = { close = { "q", "<Esc>" } } },
			render = { max_value_lines = 100 },
		},
		-- Same as LazyVim's, but dap-ui stays open when the session ends
		config = function(_, opts)
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup(opts)
			dap.listeners.before.attach.dapui_config = function()
				dapui.open({})
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open({})
			end
		end,
	},
}

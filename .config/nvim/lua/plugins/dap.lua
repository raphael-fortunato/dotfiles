return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			config = function()
				local dapui = require("dapui")
				local dap = require("dap")
				dapui.setup({
					icons = { expanded = "", collapsed = "", current_frame = "" },
					mappings = {
						-- Use a table to apply multiple mappings
						expand = { "<CR>", "<2-LeftMouse>" },
						open = "o",
						remove = "d",
						edit = "e",
						repl = "r",
						toggle = "t",
					},
					-- Use this to override mappings for specific elements
					element_mappings = {
						-- Example:
						-- stacks = {
						--   open = "<CR>",
						--   expand = "o",
						-- }
					},
					-- Expand lines larger than the window
					-- Requires >= 0.7
					expand_lines = vim.fn.has("nvim-0.7") == 1,
					-- Layouts define sections of the screen to place windows.
					-- The position can be "left", "right", "top" or "bottom".
					-- The size specifies the height/width depending on position. It can be an Int
					-- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
					-- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
					-- Elements are the elements shown in the layout (in order).
					-- Layouts are opened in order so that earlier layouts take priority in window sizing.
					layouts = {
						{
							elements = {
								-- Elements can be strings or table with id and size keys.
								{ id = "scopes", size = 0.25 },
								"breakpoints",
								"stacks",
								"watches",
							},
							size = 40, -- 40 columns
							position = "left",
						},
						{
							elements = {
								"repl",
								"console",
							},
							size = 0.25, -- 25% of total lines
							position = "bottom",
						},
					},
					controls = {
						-- Requires Neovim nightly (or 0.8 when released)
						enabled = true,
						-- Display controls in this element
						element = "repl",
						icons = {
							pause = "",
							play = "",
							step_into = "",
							step_over = "",
							step_out = "",
							step_back = "",
							run_last = "",
							terminate = "",
						},
					},
					floating = {
						max_height = nil, -- These can be integers or a float between 0 and 1.
						max_width = nil, -- Floats will be treated as percentage of your screen.
						border = "single", -- Border style. Can be "single", "double" or "rounded"
						mappings = {
							close = { "q", "<Esc>" },
						},
					},
					windows = { indent = 1 },
					render = {
						max_type_length = nil, -- Can be integer or nil.
						max_value_lines = 100, -- Can be integer or nil.
					},
				})
				dap.listeners.before.attach.dapui_config = function()
					dapui.open()
				end
				dap.listeners.before.launch.dapui_config = function()
					dapui.open()
				end
				-- dap.listeners.before.event_terminated.dapui_config = function()
				-- 	dapui.close()
				-- end
				-- dap.listeners.before.event_exited.dapui_config = function()
				-- 	dapui.close()
				-- end
			end,
		},
		"nvim-telescope/telescope-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"jbyuki/one-small-step-for-vimkind",

		{
			"mfussenegger/nvim-dap-python",
			config = function()
				require("dap-python").setup("/home/raphael/nvim/bin/python")
			end,
		},
	},
	config = function()
		require("nvim-dap-virtual-text").setup()
		require("dap-python").setup("python")
		local dap = require("dap")
		dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

		dap.adapters.cppdbg = {
			type = "executable",
			command = "/home/raphael/builds/cpptools/debugAdapters/bin/OpenDebugAD7", -- adjust as needed, must be absolute path
			name = "cppdbg",
			id = "cppdbg",
		}
		dap.adapters.codelldb = {
			type = "executable",
			command = "/usr/bin/codelldb", -- adjust as needed, must be absolute path
			name = "codelldb",
			id = "code-lldb",
		}

		dap.adapters.python = function(cb, config)
			if config.preLaunchTask then
				print(vim.inspect(config.preLaunchTask))
				vim.fn.system(config.preLaunchTask)
			end
			local adapter = {
				type = "executable",
				command = "python",
				args = { "-m", "debugpy" },
			}
			cb(adapter)
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
						local parsed_line = line:match("%((.-)%)")
						parsed_line = vim.fn.split(parsed_line:gsub("%s", ""), ",")
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
					print("ola ola")
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

		require("dap-python").setup(vim.fn.expand("~/nvim/bin/python"))
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
				args = {
					"--tester-type",
					"BUILD_SERVER",
					"--tags=@raph",
					"--stop",
				},
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
				-- args = {
				-- 	function()
				-- 		local args = vim.fn.input("Optional Arguments: ")
				-- 		print(args)
				-- 		if args and args ~= "" then
				-- 			print(vim.inspect(vim.split(args, " ")))
				-- 			return vim.split(args, " ")
				-- 		end
				-- 		return nil
				-- 	end,
				-- },
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
				-- args = {
				-- 	function()
				-- 		local args = vim.fn.input("Optional Arguments: ")
				-- 		print(args)
				-- 		if args and args ~= "" then
				-- 			print(vim.inspect(vim.split(args, " ")))
				-- 			return vim.split(args, " ")
				-- 		end
				-- 		return nil
				-- 	end,
				-- },
				pythonPath = "python",
			},
		}
		dap.configurations.javascript = {
			{
				{
					type = "firefox",
					request = "launch",
					name = "Launch Edge against localhost",
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}",
				},
			},
		}

		dap.configurations.typescript = dap.configurations.javascript
		dap.configurations.lua = {
			{
				type = "nlua",
				request = "attach",
				name = "Attach to running Neovim instance",
			},
		}

		dap.adapters.nlua = function(callback, config)
			callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
		end
		vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
		vim.keymap.set("n", "<F6>", ":lua require'dap'.step_over()<CR>")
		vim.keymap.set("n", "<F7>", ":lua require'dap'.step_into()<CR>")
		vim.keymap.set("n", "<F8>", ":lua require'dap'.continue()<CR>")
		vim.keymap.set("n", "<F10>", ":lua require('osv').launch({port = 8086})<CR>", { noremap = true })
		vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
		vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
		vim.keymap.set("n", "<leader>dc", ":lua require'dapui'.close()<CR>")

		vim.keymap.set(
			"n",
			"<leader>lp",
			":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point messages: '))<CR>"
		)
		vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")
		vim.keymap.set("n", "<F4>", function()
			-- (Re-)reads launch.json if present
			if vim.fn.filereadable(".vscode/launch.json") then
				require("dap.ext.vscode").load_launchjs(nil, { cpptools = { "c", "cpp" } })
			end
			require("dap").continue()
		end, { desc = "DAP Continue" })
	end,
	require("dap").set_log_level("TRACE"),
}

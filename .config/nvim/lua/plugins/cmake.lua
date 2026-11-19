-- cmake-tools comes from the lang.cmake extra; these are your opts.
-- Keys moved from <leader>c* (LazyVim's code group) to <leader>C*.
return {
	"Civitasv/cmake-tools.nvim",
	keys = {
		{ "<leader>C", "", desc = "+cmake", ft = { "c", "cpp", "cmake" } },
		{ "<leader>Cg", "<cmd>CMakeGenerate<cr>", desc = "CMake generate" },
		{ "<leader>Cb", "<cmd>CMakeBuild<cr>", desc = "CMake build" },
		{ "<leader>Cr", "<cmd>CMakeRun<cr>", desc = "CMake run target" },
		{ "<leader>Cd", "<cmd>CMakeDebug<cr>", desc = "CMake debug target" },
		{ "<leader>Cs", "<cmd>CMakeStopExecutor<cr>", desc = "CMake stop executor" },
		{ "<leader>Cc", "<cmd>CMakeClean<cr>", desc = "CMake clean" },
		{ "<leader>Ci", "<cmd>CMakeInstall<cr>", desc = "CMake install" },
		{ "<leader>Ct", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "Select launch target" },
		{ "<leader>CT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "Select build target" },
		{ "<leader>Cv", "<cmd>CMakeSelectBuildType<cr>", desc = "Select build type" },
		{ "<leader>Cp", "<cmd>CMakeSelectConfigurePreset<cr>", desc = "Select configure preset" },
		{ "<leader>Ca", "<cmd>CMakeLaunchArgs<cr>", desc = "Set launch arguments" },
		{ "<leader>Co", "<cmd>CMakeOpenExecutor<cr>", desc = "Open build output" },
		{ "<leader>Cq", "<cmd>CMakeCloseExecutor<cr>", desc = "Close build output" },
	},
	opts = {
		cmake_build_directory = "build",
		cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
		-- compile_commands.json is already symlinked into the project root
		cmake_compile_commands_options = { action = "none" },
		cmake_dap_configuration = {
			name = "cpp",
			type = "cppdbg",
			request = "launch",
			stopAtEntry = false,
			MIMode = "gdb",
			miDebuggerPath = "/usr/bin/gdb",
			setupCommands = {
				{ text = "-enable-pretty-printing", ignoreFailures = true },
			},
		},
		-- Quickfix output pairs with nvim-bqf and the >q / <q maps
		cmake_executor = {
			name = "quickfix",
			default_opts = {
				quickfix = { show = "only_on_error", position = "belowright", size = 10 },
			},
		},
		cmake_runner = { name = "terminal" },
	},
}

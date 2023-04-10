vim.fn.sign_define("passed", { text = "✓", texthl = "testpassed" })
local ns = vim.api.nvim_create_namespace("live-tests")
local diagnostic_buf = vim.api.nvim_create_buf(false, true)
local comp_buf = vim.api.nvim_create_buf(false, true)

local print_scenario_header = function(buf, key)
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "" })
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "------------------------" })
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { key })
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "------------------------" })
end

local add_feature_result = function(state_obj, entry)
	assert(entry.status, vim.inspect(entry))
	assert(entry.location, vim.inspect(entry))
	state_obj.feature = {
		location = tonumber(vim.split(entry.location, ":")[2]) - 1,
		status = entry.status,
	}
end

local add_step_result = function(step_data, entry)
	for _, step in ipairs(entry.steps) do
		if step.status ~= "passed" and step.result ~= nil then
			assert(step.result.status, vim.inspect(step.result))
			if step.result.status ~= "passed" then
				assert(step.location, vim.inspect(step))
				assert(step.location, vim.inspect(step.result))
				step_data.error_line = tonumber(vim.split(step.location, ":")[2]) - 1
				step_data.step_status = step.result.status
				if step.result.error_message ~= nil then
					step_data.error_message = step.result.error_message[1]
					step_data.error_data = step.result.error_message
				else
					step_data.error_data = { step.result.status }
					step_data.error_message = step.result.status
				end
			end
		end
	end
end

local add_scenario_result = function(state_obj, entry)
	assert(entry.status, vim.inspect(entry))
	assert(entry.steps, vim.inspect(entry))
	assert(entry.location, vim.inspect(entry))
	local step_data = {
		error_line = nil,
		step_status = nil,
	}
	if entry.status == "skipped" then
		return
	end
	if entry.status ~= "passed" then
		add_step_result(step_data, entry)
	end
	state_obj.tests[entry.location] = {
		-- need to offset -1 to get the correct position in nvim
		line = tonumber(vim.split(entry.location, ":")[2]) - 1,
		status = entry.status,
		steps = step_data,
		location = entry.location,
	}
end

local test_runner = function(bufnr, file_path)
	print("Running Behave Tests!")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	vim.fn.sign_unplace("behave_passed")
	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(diagnostic_buf, -1, -1, false, data)
		end
	end
	local stream_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(comp_buf, -1, -1, false, data)
		end
	end

	local state = {
		bufnr = bufnr,
		feature = {},
		tests = {},
	}
	local node_argument = vim.split(vim.fn.expand("%"), "/")[2] .. ":" .. "main"
	if string.match(vim.fn.expand("%"), "component") then
		vim.cmd.new()
		local win = vim.api.nvim_get_current_win()
		win = vim.api.nvim_win_set_buf(win, comp_buf)
		print_scenario_header(comp_buf, file_path)
		vim.fn.jobstart({
			"python",
			"/home/raphael/work/simplicity/test/mocks/mocks/module_patch/module_patch.py",
			node_argument,
			"-s",
			"250",
			"--stoppable",
			"--log",
			"INFO",
		}, {
			stdout_buffered = true,
			on_stderr = stream_data,
			on_stdout = stream_data,
		})
	end

	vim.fn.jobstart({ "behave", "-f", "json", file_path }, {
		stdout_buffered = true,
		on_stderr = append_data,
		on_stdout = function(_, data)
			if not data then
				print("No test data found")
				return
			end
			for _, line in ipairs(data) do
				if vim.startswith(line, "{") then
					line = string.gsub(line, "}Stopping adapter 'dds'", "}")
					local decoded = vim.json.decode(line)
					if decoded.keyword == "Feature" then
						add_feature_result(state, decoded)
						for _, scenario in ipairs(decoded.elements) do
							if scenario.type == "scenario" then
								add_scenario_result(state, scenario)
							end
						end
					end
				end
			end
		end,
		on_exit = function()
			vim.api.nvim_buf_set_lines(diagnostic_buf, -1, -1, false, { "Behave Test Output" })
			local failed = {}
			if state.feature.status == "passed" then
				print("Test passed!")
				vim.fn.sign_place(
					0,
					"behave_passed",
					"passed",
					bufnr,
					{ lnum = state.feature.location + 1, priority = 1000 }
				)
				vim.api.nvim_buf_set_extmark(bufnr, ns, state.feature.location, 0, {
					virt_text = { { "Passed", "TestPassed" } },
				})
			else
				print("Test failed!")
				table.insert(failed, {
					bufnr = bufnr,
					lnum = state.feature.location,
					col = 0,
					severity = vim.diagnostic.severity.ERROR,
					source = "behave",
					message = "Feature Failed",
					user_data = {},
				})
			end
			for key, test in pairs(state.tests) do
				if test.line then
					if test.status == "passed" then
						vim.fn.sign_place(
							0,
							"behave_passed",
							"passed",
							bufnr,
							{ lnum = test.line + 1, priority = 1000 }
						)
						vim.api.nvim_buf_set_extmark(bufnr, ns, test.line, 0, {
							virt_text = { { "Passed", "TestPassed" } },
						})
					else
						-- Set Scenario
						print_scenario_header(diagnostic_buf, key)
						table.insert(failed, {
							bufnr = bufnr,
							lnum = test.line,
							col = 0,
							severity = vim.diagnostic.severity.ERROR,
							source = "behave",
							message = "Test Failed",
							user_data = {},
						})
						-- Set error line if error exist
						if test.steps.error_line ~= nil and test.steps.error_message ~= nil then
							for _, line in ipairs(test.steps.error_data) do
								vim.api.nvim_buf_set_lines(diagnostic_buf, -1, -1, false, { line })
							end
							table.insert(failed, {
								bufnr = bufnr,
								lnum = test.steps.error_line,
								col = 0,
								severity = vim.diagnostic.severity.ERROR,
								source = "behave",
								message = test.steps.error_message,
								user_data = {},
							})
						end
					end
				end
			end

			vim.diagnostic.set(ns, bufnr, failed, {})
		end,
	})
end

local attach_to_buffer = function(run_pattern, bufnr, file_path)
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("BehaveRunner", { clear = true }),
		pattern = run_pattern,
		callback = function()
			local nr = bufnr
			local path = file_path
			test_runner(nr, path)
		end,
	})
end

vim.api.nvim_create_user_command("AttachRunner", function()
	local file_path = vim.fn.expand("%:p")
	local test_case = vim.fn.input("Scenario: ")
	if test_case ~= "" then
		file_path = file_path .. ":" .. test_case
	end
	print("File path = " .. file_path)

	local bufnr = tonumber(vim.fn.input("Bufnr: "))
	if bufnr ~= "" then
		bufnr = vim.api.nvim_get_current_buf()
		print("current bufnr = " .. bufnr)
	end

	local pattern = vim.split(vim.fn.input("Pattern: "), " ")
	if pattern == "" then
		pattern = "*." .. vim.fn.expand("%:e")
	end
	print("current pattern = " .. vim.inspect(pattern))

	attach_to_buffer(pattern, bufnr, file_path)
end, {})

vim.api.nvim_create_user_command("RunNearestTest", function()
	local file_path = vim.fn.expand("%:p") .. ":" .. vim.api.nvim__buf_stats(0).current_lnum
	local bufnr = vim.api.nvim_get_current_buf()
	test_runner(bufnr, file_path)
end, {})

vim.api.nvim_create_user_command("RunFileTest", function()
	local file_path = vim.fn.expand("%:p")
	local bufnr = vim.api.nvim_get_current_buf()
	test_runner(bufnr, file_path)
end, {})

vim.api.nvim_create_user_command("TestDiagnostic", function()
	vim.cmd.new()
	local win = vim.api.nvim_get_current_win()
	win = vim.api.nvim_win_set_buf(win, diagnostic_buf)
end, {})

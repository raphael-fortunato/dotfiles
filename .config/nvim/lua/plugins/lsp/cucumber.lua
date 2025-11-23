return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.cucumber_language_server.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		offset_encoding = "utf-16",
		root_dir = nvim_lsp.util.root_pattern("environment.py"),
		filetypes = { "cucumber" },
		cmd = { vim.fn.expand("~/builds/cucumber-language-server/bin/cucumber-language-server.cjs"), "--stdio" },
		settings = {
			strictGherkinCompletion = true,
			cucumber = {
				features = { "features/*.feature" },
				glue = {
					"steps/*.py",
					"../../../../test/mocks/mocks/steps/*_steps.py",
					"../../../../test/mocks/mocks/steps/component_steps.py",
					"../../../../test/mocks/mocks/steps/time_flow_steps.py",
					"../../../../test/mocks/mocks/steps/dds_steps.py",
					"../../../../test/mocks/mocks/steps/recipy_steps.py",
					"../../../../test/mocks/mocks/steps/arm_steps.py",
					"../../../../test/mocks/mocks/steps/milking_steps.py",
					"../../../../test/mocks/mocks/steps/fluids_controller_steps.py",
					"../../../../test/mocks/mocks/steps/cleaning_steps.py",
				},
				parameterTypes = {},
			},
			features = { "features/*.feature" },
			glue = {
				"steps/*.py",
				"../../../../test/mocks/mocks/steps/*_steps.py",
				"../../../../test/mocks/mocks/steps/component_steps.py",
				"../../../../test/mocks/mocks/steps/time_flow_steps.py",
				"../../../../test/mocks/mocks/steps/dds_steps.py",
				"../../../../test/mocks/mocks/steps/recipy_steps.py",
				"../../../../test/mocks/mocks/steps/arm_steps.py",
				"../../../../test/mocks/mocks/steps/milking_steps.py",
				"../../../../test/mocks/mocks/steps/fluids_controller_steps.py",
				"../../../../test/mocks/mocks/steps/cleaning_steps.py",
			},
			parameterTypes = {},
		},
	})
end

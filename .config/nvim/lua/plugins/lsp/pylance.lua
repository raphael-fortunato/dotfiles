return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")
	local nvim_lsp_config = require("lspconfig.configs")
	local pylance = require("pylance")

	pylance.setup()
	nvim_lsp_config.pylance = {
		default_config = {
			-- https://github.com/microsoft/pylance-release#settings-and-customization
			cmd = {
				"node",
				vim.fn.expand("~/.local/share/nvim/lsp_servers/pylance2/dist/server.bundle.js"),
				"--stdio",
			},
			autostart = true,
			settings = {
				python = {
					analysis = {
						indexing = true,
						diagnosticMode = "workspace",
						autoFormatStrings = true,
						autoSearchPaths = true,
						stubPath = "",
						extraPaths = {},
						useLibraryCodeForTypes = true,
						logLevel = "Information",
						typeCheckingMode = "basic",
						autoImportCompletions = true,
						diagnosticSeverityOverrides = {
							reportMissingParameterType = "none",
							reportUnknownParameterType = "none",
							reportMissingTypeArgument = "none",
							reportGeneralTypeIssues = "none",
							reportOptionalMemberAccess = "none",
							reportOptionalSubscript = "none",
							reportPrivateImportUsage = "none",
							reportUnknownArgumentType = "none",
							reportUnknownLambdaType = "none",
							reportUnknownVariableType = "none",
							reportUnknownMemberType = "none",
							reportMissingTypeStubs = "none",
							reportUntypedFunctionDecorator = "none",
							reportUntypedClassDecorator = "none",
							reportUntypedBaseClass = "none",
							reportUntypedNamedTuple = "none",
							reportCallInDefaultInitializer = "none",
							reportArgumentType = "none",
							reportAssignmentType = "none",
							reportAttributeAccessIssue = "none",
							reportCallIssue = "none",
							reportInconsistentConstructor = "none",
							reportIncompatibleMethodOverride = "none",
							reportIncompatibleVariableOverride = "none",
							reportIndexIssue = "none",
							reportInvalidTypeVarUse = "none",
							reportNoReturnReturnsNone = "none",
							reportOperatorIssue = "none",
							reportOverlappingOverload = "none",
							reportPossiblyUnboundVariable = "none",
							reportReturnType = "none",
							reportTypedDictNotRequiredAccess = "none",
							reportUnboundVariable = "none",
							reportUndefinedVariable = "none",
							reportUnnecessaryIsInstance = "none",
							reportUnnecessaryCast = "none",
							reportUnsupportedDunderAll = "none",
							reportWildcardImportFromLibrary = "none",
						},
						inlayHints = {
							variableTypes = true,
							functionReturnTypes = true,
							pytestParameters = true,
						},
					},
				},
				telemetry = {
					telemetryLevel = "off",
				},
				pyright = {
					configurationSources = { "flake8" },
					plugins = {
						pycodestyle = { enabled = false },
						flake8 = { enabled = true },
						mypy = {
							enabled = true,
							live_mode = true,
							strict = true,
						},
					},
				},
			},
			root_dir = nvim_lsp.util.root_pattern("pyrightconfig.json", ".git"),
		},
	}

	-- Pylance utility functions
	local function organize_imports()
		local params = {
			command = "pyright.organizeimports",
			arguments = { vim.uri_from_bufnr(0) },
		}
		vim.lsp.buf.execute_command(params)
	end

	local function extract_variable()
		local pos_params = vim.lsp.util.make_given_range_params()
		local params = {
			command = "pylance.extractVariable",
			arguments = {
				vim.api.nvim_buf_get_name(0),
				pos_params.range,
			},
		}
		vim.lsp.buf.execute_command(params)
	end

	local function extract_method()
		local pos_params = vim.lsp.util.make_given_range_params()
		local params = {
			command = "pylance.extractMethod",
			arguments = {
				vim.api.nvim_buf_get_name(0),
				pos_params.range,
			},
		}
		vim.lsp.buf.execute_command(params)
	end

	nvim_lsp.pylance.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "python" },
		offset_encoding = "utf-16",
	})

	-- Return utility functions for external use
	return {
		organize_imports = organize_imports,
		extract_variable = extract_variable,
		extract_method = extract_method,
	}
end

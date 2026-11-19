local cucumber_ls = vim.fn.expand("~/builds/cucumber-language-server/bin/cucumber-language-server.cjs")
local has_local_cucumber = vim.fn.filereadable(cucumber_ls) == 1

local cucumber_glue = {
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
}

local ts_inlay_hints = {
	includeInlayParameterNameHints = "all",
	includeInlayParameterNameHintsWhenArgumentMatchesName = true,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayVariableTypeHints = true,
	includeInlayVariableTypeHintsWhenTypeMatchesName = true,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayEnumMemberValueHints = true,
}

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			diagnostics = {
				underline = false,
				float = { border = "rounded", source = true, header = "", prefix = "" },
			},
			servers = {
				clangd = {
					cmd = {
						"clangd",
						"--background-index",
						"--header-insertion=iwyu",
						"--offset-encoding=utf-16",
						"--function-arg-placeholders",
						"--all-scopes-completion",
						"--completion-style=detailed",
						"--header-insertion-decorators",
						"--clang-tidy",
						"--clang-tidy-checks=bugprone-*,performance-*,readability-*,modernize-*",
						"--cross-file-rename",
						"--limit-results=50",
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							hint = { enable = true },
							diagnostics = { globals = { "vim", "awesome" } },
						},
					},
				},
				bashls = {},
				ts_ls = {
					settings = {
						typescript = { inlayHints = ts_inlay_hints },
						javascript = { inlayHints = ts_inlay_hints },
					},
				},
				cucumber_language_server = {
					mason = not has_local_cucumber,
					cmd = has_local_cucumber and { cucumber_ls, "--stdio" } or nil,
					root_markers = { "environment.py" },
					filetypes = { "cucumber" },
					settings = {
						strictGherkinCompletion = true,
						cucumber = {
							features = { "features/*.feature" },
							glue = cucumber_glue,
							parameterTypes = {},
						},
						features = { "features/*.feature" },
						glue = cucumber_glue,
						parameterTypes = {},
					},
				},
				omnisharp = {
					mason = false,
					root_markers = { ".git" },
					enable_editorconfig_support = true,
					enable_ms_build_load_projects_on_demand = false,
					enable_roslyn_analyzers = false,
					organize_imports_on_format = false,
					enable_import_completion = false,
					sdk_include_prereleases = true,
					analyze_open_documents_only = false,
				},
				ghcide = {
					mason = false,
					cmd = { "haskell-language-server-9.2.5", "--lsp" },
					filetypes = { "haskell", "lhaskell" },
					root_markers = { "stack.yaml", ".git" },
				},
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"prettier",
				"stylua",
				"isort",
				"black",
				"pylint",
				"ruff",
				"mypy",
				"luacheck",
				"cpptools",
				"shfmt",
				"shellcheck",
				"codespell",
				"rustfmt",
			},
		},
	},
}

return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.clangd.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "c", "cpp", "objc", "objcpp", "*.CPP", "*.H", "*.idl" },
		root_dir = nvim_lsp.util.root_pattern(".git"),
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
	})
end

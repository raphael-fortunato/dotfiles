return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.ghcide.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = { "haskell-language-server-9.2.5", "--lsp" },
		filetypes = { "haskell", "lhaskell" },
		root_dir = nvim_lsp.util.root_pattern("stack.yaml", ".git"),
		offset_encoding = "utf-16",
	})
end

return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.bashls.setup({
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh" },
		on_attach = on_attach,
		capabilities = capabilities,
		offset_encoding = "utf-16",
	})
end

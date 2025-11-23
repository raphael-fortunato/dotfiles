return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.yamlls.setup({
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose" },
		on_attach = on_attach,
		capabilities = capabilities,
		offset_encoding = "utf-16",
	})
end

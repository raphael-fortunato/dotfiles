return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	nvim_lsp.lua_ls.setup({
		on_attach = on_attach,
		offset_encoding = "utf-16",
		commands = {
			Format = {
				function()
					require("stylua-nvim").format_file()
				end,
			},
		},
		settings = {
			Lua = {
				hint = {
					enable = true,
				},
				diagnostics = {
					globals = { "vim", "awesome" },
				},
			},
		},
	})
end

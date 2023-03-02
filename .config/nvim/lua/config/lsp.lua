require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"pyright",
		"pylint",
		"flake8",
		"isort",
		"clangd",
		"sumneko_lua",
		"luacheck",
		"rust_analyzer",
		"hls",
		"bashls",
		"cmake",
		"vimls",
		"cucumber_language_server",
	},
})

local nvim_lsp = require("lspconfig")
local lspconfig_util = require("lspconfig.util")
local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

vim.fn.sign_define("DiagnosticSignError", {
	text = " ",
	texthl = "DiagnosticError",
})
vim.fn.sign_define("DiagnosticSignWarn", {
	text = " ",
	texthl = "DiagnosticWarn",
})
vim.fn.sign_define("DiagnosticSignInfo", {
	text = " ",
	texthl = "DiagnosticInfo",
})
vim.fn.sign_define("DiagnosticSignHint", {
	text = "ﯦ ",
	texthl = "DiagnosticHint",
})

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false,
	underline = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

local on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("i", "gk", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "<C-n>", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>gf", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "gk", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>dd", vim.diagnostic.disable)
	vim.keymap.set("n", "<leader>de", vim.diagnostic.enable)
	vim.keymap.set("n", "gs", ":ClangdSwitchSourceHeader<CR>")

	vim.api.nvim_create_autocmd("ModeChanged", {
		pattern = { "n:i", "v:s" },
		desc = "Disable diagnostics while typing",
		callback = function()
			vim.diagnostic.disable(0)
		end,
	})

	vim.api.nvim_create_autocmd("ModeChanged", {
		pattern = "i:n",
		desc = "Enable diagnostics when leaving insert mode",
		callback = function()
			vim.diagnostic.enable(0)
		end,
	})
	require("nvim-navic").attach(client, bufnr)
end

nvim_lsp.pyright.setup({
	on_attach = on_attach,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
			},
		},
		cmd = {
			"pyright-langserver",
			"--stdio",
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
	capabilities = capabilities,
	filetypes = { "python" },
	root_dir = nvim_lsp.util.root_pattern("pyrightconfig.json", ".git"),
})

nvim_lsp.clangd.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "c", "cpp", "objc", "objcpp", "idl" },
	root_dir = nvim_lsp.util.root_pattern(".git"),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--offset-encoding=utf-16",
		-- "--compile-commands-dir=compile-commands.json",
	},
})

require("lspconfig").ghcide.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	cmd = { "haskell-language-server-9.2.5", "--lsp" },
	filetypes = { "haskell", "lhaskell" },
	root_dir = nvim_lsp.util.root_pattern("stack.yaml", ".git"),
})

require("lspconfig").sumneko_lua.setup({
	on_attach = on_attach,
	commands = {
		Format = {
			function()
				require("stylua-nvim").format_file()
			end,
		},
	},
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "awesome" },
			},
		},
	},
})

-- nvim_lsp.cucumber_language_server.setup({
-- 	root_dir = nvim_lsp.util.root_pattern("environment.py"),
-- 	filetypes = { "cucumber" },
-- 	cmd = { vim.fn.expand("~/Downloads/language-server/bin/cucumber-language-server.cjs"), "--stdio" },
-- 	settings = {
-- 		cucumber = {
-- 			features = { "**/*.feature" },
-- 			glue = {
-- 				vim.fn.expand("~/work/simplicity/test/mocks/mocks/steps/*.py"),
-- 				"**/steps/*.py",
-- 			},
-- 		},
-- 	},
-- })

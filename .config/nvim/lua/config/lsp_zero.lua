local lsp = require("lsp-zero")
local lsp_config = require("lspconfig")

lsp.preset("recommended")

lsp.ensure_installed({
	"pyright",
	"clangd",
	"sumneko_lua",
	"rust_analyzer",
	"hls",
	"bashls",
	-- "cmake",
	"vimls",
	"cucumber_language_server",
})

-- Fix Undefined global 'vim'
lsp.configure("sumneko_lua", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

lsp.configure("cucumber_language_server", {
	root_dir = lsp_config.util.root_pattern("environment.py"),
	filetypes = { "cucumber" },
	cmd = { vim.fn.expand("~/Downloads/language-server/bin/cucumber-language-server.cjs"), "--stdio" },
	settings = {
		cucumber = {
			features = { "**/*.feature" },
			glue = {
				vim.fn.expand("~/work/simplicity/test/mocks/mocks/steps/*.py"),
				"steps/*.py",
			},
		},
	},
})
lsp.nvim_workspace({
	root_dir = lsp_config.util.root_pattern(".git"),
})

lsp.configure("pyright", {
	filetypes = { "python" },
	root_dir = lsp_config.util.root_pattern("pyrightconfig.json"),
	cmd = {
		"pyright-langserver",
		"--stdio",
	},
	single_file_support = false,
})

lsp.configure("clangd", {
	filetypes = { "c", "cpp", "objc", "objcpp", "idl" },
	root_dir = lsp_config.util.root_pattern(".git"),
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		-- "--compile-commands-dir=compile-commands.json",
	},
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	["<C-y>"] = cmp.mapping.confirm({
		behavior = cmp.ConfirmBehavior.Insert,
		select = true,
	}),
	["<C-Space>"] = cmp.mapping.complete(),
})

-- disable completion with tab
-- this helps with copilot setup
cmp_mappings["<Tab>"] = nil
cmp_mappings["<S-Tab>"] = nil

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	sources = {
		{ name = "nvim_lsp" },
		{ name = "cmp_tabnine" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_lenoth = 3 },
		{ name = "path" },
		{ name = "nvim_lua" },
		{ name = "zsh" },
	},
})

lsp.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "✘",
		warn = "▲",
		hint = "⚑",
		info = "",
	},
})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, remap = false }

	if client.name == "eslint" then
		vim.cmd.LspStop("eslint")
		return
	end

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gr", ":Telescope lsp_references<CR>", opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("i", "gk", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", ">d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>gf", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "gk", vim.lsp.buf.signature_help, opts)
end)

lsp.setup()

vim.diagnostic.config({
	virtual_text = true,
})

vim.g.diagnostics_active = true
function _G.toggle_diagnostics()
	if vim.g.diagnostics_active then
		vim.g.diagnostics_active = false
		--vim.lsp.diagnostic.clear(0)
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
	else
		vim.g.diagnostics_active = true
		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = true,
			signs = true,
			underline = true,
			update_in_insert = false,
		})
	end
end

vim.api.nvim_set_keymap("n", "<leader>tt", ":call v:lua.toggle_diagnostics()<CR>", { noremap = true, silent = true })

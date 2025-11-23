return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		--{ "antosha417/nvim-lsp-file-operations", config = true },
		"lithammer/nvim-pylance",
	},
	config = function()
		local nvim_lsp = require("lspconfig")
		local nvim_lsp_config = require("lspconfig.configs")
		local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

		capabilities.textDocument.completion.completionItem.snippetSupport = true
		
		-- Set consistent offset encoding for all LSP servers
		capabilities.offsetEncoding = { "utf-16" }

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

		vim.lsp.handlers["textDocument/signatureHelp"] =
			vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

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

			vim.keymap.set("n", "gd", ":Telescope lsp_definitions<CR>", opts)
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
			vim.keymap.set("v", "<leader>gf", vim.lsp.buf.code_action, opts)
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

			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable()
			end
		end

		-- Load individual LSP configurations
		require("plugins.lsp.pylance")(on_attach, capabilities)
		require("plugins.lsp.clangd")(on_attach, capabilities)
		require("plugins.lsp.haskell")(on_attach, capabilities)
		require("plugins.lsp.lua_ls")(on_attach, capabilities)
		require("plugins.lsp.cucumber")(on_attach, capabilities)
		require("plugins.lsp.omnisharp")(on_attach, capabilities)
		require("plugins.lsp.typescript")(on_attach, capabilities)
		require("plugins.lsp.bash")(on_attach, capabilities)
		require("plugins.lsp.yaml")(on_attach, capabilities)
		require("plugins.lsp.rust_analyzer")(on_attach, capabilities)
	end,
}

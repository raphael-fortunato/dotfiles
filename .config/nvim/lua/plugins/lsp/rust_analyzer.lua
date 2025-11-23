return function(on_attach, capabilities)
	local nvim_lsp = require("lspconfig")

	-- Rust-analyzer specific settings
	local rust_analyzer_settings = {
		["rust-analyzer"] = {
			-- Enable all features
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			-- Add clippy lints for Rust.
			checkOnSave = {
				allFeatures = true,
				command = "clippy",
				extraArgs = { "--no-deps" },
			},
			procMacro = {
				enable = true,
				ignored = {
					leptos_macro = {
						-- optional: --
						-- "component",
						"server",
					},
				},
			},
			-- Inlay hints
			inlayHints = {
				bindingModeHints = {
					enable = false,
				},
				chainingHints = {
					enable = true,
				},
				closingBraceHints = {
					enable = true,
					minLines = 25,
				},
				closureReturnTypeHints = {
					enable = "never",
				},
				lifetimeElisionHints = {
					enable = "never",
					useParameterNames = false,
				},
				maxLength = 25,
				parameterHints = {
					enable = true,
				},
				reborrowHints = {
					enable = "never",
				},
				renderColons = true,
				typeHints = {
					enable = true,
					hideClosureInitialization = false,
					hideNamedConstructor = false,
				},
			},
			-- Completion settings
			completion = {
				postfix = {
					enable = true,
				},
				privateEditable = {
					enable = false,
				},
				callable = {
					snippets = "fill_arguments",
				},
			},
			-- Diagnostics
			diagnostics = {
				enable = true,
				experimental = {
					enable = true,
				},
			},
			-- Hover actions
			hover = {
				actions = {
					enable = true,
					implementations = {
						enable = true,
					},
					references = {
						enable = true,
					},
					run = {
						enable = true,
					},
					debug = {
						enable = true,
					},
				},
				documentation = {
					enable = true,
				},
			},
			-- Lens settings
			lens = {
				enable = true,
				debug = {
					enable = true,
				},
				implementations = {
					enable = true,
				},
				run = {
					enable = true,
				},
				methodReferences = {
					enable = true,
				},
				references = {
					adt = {
						enable = true,
					},
					enumVariant = {
						enable = true,
					},
					method = {
						enable = true,
					},
					trait = {
						enable = true,
					},
				},
			},
			-- Semantic tokens
			semanticHighlighting = {
				strings = {
					enable = true,
				},
			},
			-- Workspace settings
			workspace = {
				symbol = {
					search = {
						scope = "workspace_and_dependencies",
					},
				},
			},
			-- Rustfmt settings
			rustfmt = {
				extraArgs = {},
				overrideCommand = nil,
				rangeFormatting = {
					enable = false,
				},
			},
		},
	}

	-- Rust-analyzer utility functions
	local function reload_workspace()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.reloadWorkspace",
		})
	end

	local function expand_macro()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.expandMacro",
			arguments = { vim.uri_from_bufnr(0), vim.lsp.util.make_position_params().position },
		})
	end

	local function join_lines()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.joinLines",
			arguments = {
				{
					textDocument = { uri = vim.uri_from_bufnr(0) },
					ranges = { vim.lsp.util.make_given_range_params().range },
				},
			},
		})
	end

	local function structural_search_replace()
		vim.ui.input({ prompt = "Enter SSR pattern: " }, function(pattern)
			if pattern then
				vim.lsp.buf.execute_command({
					command = "rust-analyzer.ssr",
					arguments = { pattern },
				})
			end
		end)
	end

	local function view_hir()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.viewHir",
			arguments = { vim.uri_from_bufnr(0), vim.lsp.util.make_position_params().position },
		})
	end

	local function view_mir()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.viewMir",
			arguments = { vim.uri_from_bufnr(0), vim.lsp.util.make_position_params().position },
		})
	end

	local function open_cargo_toml()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.openCargoToml",
			arguments = { vim.uri_from_bufnr(0) },
		})
	end

	local function run_single()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.runSingle",
			arguments = { vim.uri_from_bufnr(0), vim.lsp.util.make_position_params().position },
		})
	end

	local function debug_single()
		vim.lsp.buf.execute_command({
			command = "rust-analyzer.debugSingle",
			arguments = { vim.uri_from_bufnr(0), vim.lsp.util.make_position_params().position },
		})
	end

	-- Custom on_attach function for Rust-specific keymaps
	local function rust_on_attach(client, bufnr)
		-- Call the base on_attach function
		if on_attach then
			on_attach(client, bufnr)
		end

		-- Rust-specific keymaps
		local opts = { buffer = bufnr, silent = true, noremap = true }
		
		-- Rust-analyzer specific commands
		vim.keymap.set("n", "<leader>rr", reload_workspace, vim.tbl_extend("force", opts, { desc = "Reload Rust workspace" }))
		vim.keymap.set("n", "<leader>rm", expand_macro, vim.tbl_extend("force", opts, { desc = "Expand macro" }))
		vim.keymap.set("n", "<leader>rj", join_lines, vim.tbl_extend("force", opts, { desc = "Join lines" }))
		vim.keymap.set("n", "<leader>rs", structural_search_replace, vim.tbl_extend("force", opts, { desc = "Structural search & replace" }))
		vim.keymap.set("n", "<leader>rh", view_hir, vim.tbl_extend("force", opts, { desc = "View HIR" }))
		vim.keymap.set("n", "<leader>rM", view_mir, vim.tbl_extend("force", opts, { desc = "View MIR" }))
		vim.keymap.set("n", "<leader>rc", open_cargo_toml, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))
		vim.keymap.set("n", "<leader>rR", run_single, vim.tbl_extend("force", opts, { desc = "Run single test/main" }))
		vim.keymap.set("n", "<leader>rD", debug_single, vim.tbl_extend("force", opts, { desc = "Debug single test/main" }))
	end

	nvim_lsp.rust_analyzer.setup({
		on_attach = rust_on_attach,
		capabilities = capabilities,
		filetypes = { "rust" },
		root_dir = nvim_lsp.util.root_pattern("Cargo.toml", "rust-project.json"),
		settings = rust_analyzer_settings,
		offset_encoding = "utf-16",
	})

	-- Return utility functions for external use
	return {
		reload_workspace = reload_workspace,
		expand_macro = expand_macro,
		join_lines = join_lines,
		structural_search_replace = structural_search_replace,
		view_hir = view_hir,
		view_mir = view_mir,
		open_cargo_toml = open_cargo_toml,
		run_single = run_single,
		debug_single = debug_single,
	}
end

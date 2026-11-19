-- rust-analyzer runs through rustaceanvim (lang.rust extra); these are your settings.
local function rust(cmd)
	return function()
		vim.cmd.RustLsp(cmd)
	end
end

return {
	"mrcjkb/rustaceanvim",
	keys = {
		{ "<leader>r", "", desc = "+rust", ft = "rust" },
		{ "<leader>rr", rust("reloadWorkspace"), ft = "rust", desc = "Reload Rust workspace" },
		{ "<leader>rm", rust("expandMacro"), ft = "rust", desc = "Expand macro" },
		{ "<leader>rj", rust("joinLines"), ft = "rust", desc = "Join lines" },
		{ "<leader>rs", rust("ssr"), ft = "rust", desc = "Structural search & replace" },
		{ "<leader>rh", rust({ "view", "hir" }), ft = "rust", desc = "View HIR" },
		{ "<leader>rM", rust({ "view", "mir" }), ft = "rust", desc = "View MIR" },
		{ "<leader>rc", rust("openCargo"), ft = "rust", desc = "Open Cargo.toml" },
		{ "<leader>rR", rust("runnables"), ft = "rust", desc = "Run test/main" },
		{ "<leader>rD", rust("debuggables"), ft = "rust", desc = "Debug test/main" },
	},
	opts = {
		server = {
			default_settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
					checkOnSave = true,
					check = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
					procMacro = { enable = true, ignored = { leptos_macro = { "server" } } },
					inlayHints = {
						bindingModeHints = { enable = false },
						chainingHints = { enable = true },
						closingBraceHints = { enable = true, minLines = 25 },
						closureReturnTypeHints = { enable = "never" },
						lifetimeElisionHints = { enable = "never", useParameterNames = false },
						maxLength = 25,
						parameterHints = { enable = true },
						reborrowHints = { enable = "never" },
						renderColons = true,
						typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
					},
					completion = {
						postfix = { enable = true },
						privateEditable = { enable = false },
						callable = { snippets = "fill_arguments" },
					},
					diagnostics = { enable = true, experimental = { enable = true } },
					hover = {
						actions = {
							enable = true,
							implementations = { enable = true },
							references = { enable = true },
							run = { enable = true },
							debug = { enable = true },
						},
						documentation = { enable = true },
					},
					lens = {
						enable = true,
						debug = { enable = true },
						implementations = { enable = true },
						run = { enable = true },
						methodReferences = { enable = true },
						references = {
							adt = { enable = true },
							enumVariant = { enable = true },
							method = { enable = true },
							trait = { enable = true },
						},
					},
					semanticHighlighting = { strings = { enable = true } },
					workspace = { symbol = { search = { scope = "workspace_and_dependencies" } } },
					rustfmt = { extraArgs = {}, rangeFormatting = { enable = false } },
				},
			},
		},
	},
}

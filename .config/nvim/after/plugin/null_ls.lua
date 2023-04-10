local nls = require("null-ls")
nls.setup({
	debounce = 150,
	save_after_format = false,
	sources = {
		-- nls.builtins.formatting.prettierd,
		nls.builtins.formatting.stylua,
		-- nls.builtins.formatting.fixjson.with({ filetypes = { "jsonc" } }),
		-- nls.builtins.formatting.eslint_d,
		-- nls.builtins.diagnostics.shellcheck,
		-- nls.builtins.formatting.shfmt,
		nls.builtins.diagnostics.markdownlint,
		nls.builtins.diagnostics.luacheck,
		nls.builtins.formatting.prettierd.with({
			filetypes = { "markdown", "json", "css", "scss", "less", "html" }, -- only runs `deno fmt` for markdown
		}),
		-- nls.builtins.diagnostics.selene.with({
		-- 	condition = function(utils)
		-- 		return utils.root_has_file({ "selene.toml" })
		-- 	end,
		-- }),
		nls.builtins.code_actions.gitsigns,
		nls.builtins.code_actions.refactoring,
		-- nls.builtins.formatting.isort,
		-- nls.builtins.diagnostics.pylint.with({
		-- 	diagnostics_postprocess = function(diagnostic)
		-- 		diagnostic.code = "no-value-for-parameter"
		-- 	end,
		-- }),
		nls.builtins.diagnostics.mypy.with({
			extra_args = { "--ignore-missing-imports" },
		}),
		nls.builtins.diagnostics.flake8.with({
			extra_args = function(params)
				-- params.root is set to the first parent dir with with either .git or
				-- Makefile
				-- These ignores will override setup.cfg
				return {
					"--ignore",
					table.concat({
						"E501", -- line too long
						"E221", -- multiple space before operators
						"E201", -- whitespace before/after '['/']'
						"E202", -- whitespace before ']'
						"E272", -- multiple spaces before keyword
						"E241", -- multiple spaces after ':'
						"E231", -- missing whitespace after ':'
						"E203", -- whitespace before ':'
						-- "E741", -- ambiguous variable name
						"E226", -- missing whitespace around arithmetic operator
						"E305",
						"E302", -- expected 2 blank lines after class
						"E251", -- unexpected spaces around keyword / parameter equals (E251)
						"W503", -- line break occurred before a binary operator
					}, ","),
				}
			end,
		}),
		nls.builtins.diagnostics.cppcheck,
	},
	root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "pyrightconfig.json", ".git"),
})

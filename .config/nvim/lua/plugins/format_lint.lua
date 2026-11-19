return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				python = { "ruff_organize_imports", "ruff_format" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
			},
			formatters = {
				-- Matches the old vim-clang-format default when no .clang-format exists
				clang_format = { prepend_args = { "--fallback-style=Google" } },
			},
		},
		init = function()
			vim.api.nvim_create_user_command("FormatDisable", function(args)
				if args.bang then
					vim.b.autoformat = false
				else
					vim.g.autoformat = false
				end
			end, { desc = "Disable format on save (! = this buffer only)", bang = true })
			vim.api.nvim_create_user_command("FormatEnable", function()
				vim.b.autoformat = nil
				vim.g.autoformat = true
			end, { desc = "Re-enable format on save" })
		end,
	},
	{
		"mfussenegger/nvim-lint",
		opts = {
			linters_by_ft = {
				python = { "codespell" },
				lua = { "luacheck" },
				cpp = { "cppcheck" },
				sh = { "shellcheck" },
				["*"] = { "codespell" },
			},
			-- Functions (not tables) so these args replace the defaults instead of merging into them
			linters = {
				cppcheck = function()
					local l = vim.deepcopy(require("lint.linters.cppcheck"))
					l.args = { "--enable=all", "--suppress=missingIncludeSystem" }
					return l
				end,
				pylint = function()
					local l = vim.deepcopy(require("lint.linters.pylint"))
					l.args = { "-f", "json" }
					return l
				end,
				mypy = function()
					local l = vim.deepcopy(require("lint.linters.mypy"))
					l.args = {
						"--python-executable",
						vim.fn.expand("~/work/simplicity/venv/bin/python"),
						"--show-column-numbers",
						"--show-error-end",
						"--hide-error-context",
						"--no-color-output",
						"--no-error-summary",
						"--no-pretty",
					}
					return l
				end,
			},
		},
	},
}

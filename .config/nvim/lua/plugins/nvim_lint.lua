return {
	"mfussenegger/nvim-lint",
	event = { "BufWritePost", "BufReadPost", "InsertLeave" },

	config = function()
		-- Event to trigger linters
		require("lint").linters_by_ft = {
			python = { "ruff", "codespell" },
			lua = { "luacheck" },
			cpp = { "cppcheck" },
			markdown = { "markdownlint" },
			shell = { "shellcheck" },
			["*"] = { "codespell" },
			-- Use the "*" filetype to run linters on all filetypes.
			--
			-- ['*'] = { 'global linter' },
			-- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
			-- ['_'] = { 'fallback linter' },
		}
		-- LazyVim extension to easily override linter options
		-- or add custom linters.
		---@type table<string,table>
		-- linters = {
		--     -- -- Example of using selene only when a selene.toml file is present
		--     -- selene = {
		--     --   -- `condition` is another LazyVim extension that allows you to
		--     --   -- dynamically enable/disable linters based on the context.
		--     --   condition = function(ctx)
		--     --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
		--     --   end,
		--     -- },
		-- }

		local pylint = require("lint").linters.pylint
		pylint.args = {
			"-f",
			"json",
		}
		local mypy = require("lint").linters.mypy
		mypy.args = {
			-- "--config-file",
			-- vim.fn.expand("~/work/simplicity/mypy.ini"),
			"--python-executable",
			vim.fn.expand("~/work/simplicity/venv/bin/python"),
			"--show-column-numbers",
			"--show-error-end",
			"--hide-error-context",
			"--no-color-output",
			"--no-error-summary",
			"--no-pretty",
		}
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				require("lint").try_lint()
			end,
		})
		vim.keymap.set("n", "<leader>ll", function()
			require("lint").try_lint()
		end, { desc = "Trigger linting for current file" })
		require("lint").try_lint()
	end,
}

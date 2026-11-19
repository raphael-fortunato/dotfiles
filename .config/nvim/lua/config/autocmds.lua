-- Loaded on VeryLazy. LazyVim defaults:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
local function augroup(name)
	return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Use built-in gq (honours textwidth) instead of conform's formatexpr
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("markdown_gq"),
	pattern = "markdown",
	callback = function()
		vim.opt_local.formatexpr = ""
		vim.opt_local.textwidth = 80
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("c_makeprg"),
	pattern = { "c", "cpp" },
	command = "setlocal makeprg=make\\ -C\\ build\\ EXTRA_CFLAGS=-fcolor-diagnostics",
})

-- Format on save only for these filetypes (<leader>cf formats the rest on demand)
local format_on_save = { lua = true, c = true, cpp = true, python = true }
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("autoformat_ft"),
	callback = function(args)
		if not format_on_save[vim.bo[args.buf].filetype] then
			vim.b[args.buf].autoformat = false
		end
	end,
})

-- Hide diagnostics while typing
local typing = augroup("diagnostics_while_typing")
vim.api.nvim_create_autocmd("ModeChanged", {
	group = typing,
	pattern = { "n:i", "v:s" },
	callback = function(args)
		if vim.diagnostic.is_enabled({ bufnr = args.buf }) then
			vim.b[args.buf].diag_hidden_while_typing = true
			vim.diagnostic.enable(false, { bufnr = args.buf })
		end
	end,
})
-- Only re-enable what was hidden above, so manual toggles (<leader>ud) stick
vim.api.nvim_create_autocmd("ModeChanged", {
	group = typing,
	pattern = "i:n",
	callback = function(args)
		if vim.b[args.buf].diag_hidden_while_typing then
			vim.b[args.buf].diag_hidden_while_typing = nil
			vim.diagnostic.enable(true, { bufnr = args.buf })
		end
	end,
})

require("modules")

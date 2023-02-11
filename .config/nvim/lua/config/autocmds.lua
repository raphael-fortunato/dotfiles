-- open vim on closing line
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*" },
	callback = function()
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			vim.api.nvim_exec("normal! g'\"", false)
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	once = false,
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 300, on_visual = true })
	end,
})

vim.api.nvim_create_autocmd("VimResized", { pattern = { "*" }, command = "wincmd =" })
vim.api.nvim_create_autocmd(
	"BufWritePre",
	{ pattern = { "*.lua" }, command = "lua require('stylua-nvim').format_file()" }
)
vim.api.nvim_create_autocmd("BufWritePre", { pattern = { "*.py, *.pyi" }, command = "call Black()" })

vim.api.nvim_create_autocmd(
	"BufWritePre",
	{ pattern = { "*.c, *.cc", ".cpp", ".h", ".hpp", ".idl" }, command = "ClangFormat" }
)

vim.api.nvim_create_autocmd("BufWritePre", { command = "lua vim.lsp.buf.format()" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*.c, *.cc", ".cpp", ".h", ".hpp", ".idl" },
	command = "set makeprg=make -C build EXTRA_CFLAGS=-fcolor-diagnostics",
})
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "*.feature" },
-- 	command = "lua vim.keymap.set('n', 'gd', require('GoBehave').goto_definition)",
-- })

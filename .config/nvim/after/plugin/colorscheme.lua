vim.g.gruvbox_baby_transparent_mode = 1
vim.g.gruvbox_baby_telescope_theme = 1
vim.g.gruvbox_baby_highlights = {
	Normal = { fg = "#123123", bg = "NONE", style = "underline" },
	Comment = { fg = "#e7d7ad", bg = "None" },
}
-- vim.g.gruvbox_baby_comment_style = "#e7d7ad"
vim.g.gruvbox_baby_function_style = "NONE"
vim.g.gruvbox_baby_keyword_style = "italic"
vim.g.gruvbox_baby_highlights = { Comment = { fg = "#e7d7ad" } }
vim.g.gruvbox_baby_highlights = { ["@comment"] = { fg = "#504945" } }
require("kanagawa").setup({
	compile = false, -- enable compiling the colorscheme
	undercurl = true, -- enable undercurls
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	typeStyle = {},
	transparent = true, -- do not set background color
	dimInactive = false, -- dim inactive window `:h hl-NormalNC`
	terminalColors = true, -- define vim.g.terminal_color_{0,17}
	colors = { -- add/modify theme and palette colors
		palette = {},
		theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
	},
	overrides = function(colors) -- add/modify highlights
		return {}
	end,
	theme = "wave", -- Load "wave" theme when 'background' option is not set
	background = { -- map the value of 'background' option to a theme
		dark = "wave", -- try "dragon" !
		light = "lotus",
	},
})
vim.cmd("colorscheme kanagawa")
-- vim.cmd([[colorscheme gruvbox-baby]])
vim.cmd([[highlight FidgetTitle ctermfg=110 ctermbg=NONE guibg=NONE guifg=#d4879c]])
vim.cmd([[highlight FidgetTitle  ctermbg=NONE guibg=NONE]])

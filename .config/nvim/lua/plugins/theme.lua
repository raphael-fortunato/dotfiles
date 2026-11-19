-- Neon synthwave theme. Try others live with <leader>uC.
return {
	{
		"maxmx03/fluoromachine.nvim",
		lazy = false,
		priority = 1000,
		opts = { glow = true, theme = "retrowave", transparent = false },
		config = function(_, opts)
			require("fluoromachine").setup(opts)
		end,
	},
	{ "LazyVim/LazyVim", opts = { colorscheme = "fluoromachine" } },
}

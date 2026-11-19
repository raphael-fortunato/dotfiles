return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
	ft = { "markdown" },
	build = "cd app && bash install.sh",
	init = function()
		vim.g.mkdp_echo_preview_url = 1
		vim.g.mkdp_preview_options = {
			mkit = {},
			katex = {},
			uml = {},
			maid = { theme = "dark" },
			disable_sync_scroll = 0,
			sync_scroll_type = "middle",
			hide_yaml_meta = 1,
			sequence_diagrams = {},
			flowchart_diagrams = {},
			content_editable = false,
			disable_filename = 0,
			toc = {},
		}

		-- Hand the preview URL to the Windows default browser; WSL2 forwards
		-- localhost from Windows into the distro.
		vim.cmd([[
			function! MkdpOpenInWindowsBrowser(url) abort
				call jobstart(['/mnt/c/Windows/explorer.exe', a:url], {'detach': v:true})
			endfunction
		]])
		vim.g.mkdp_browserfunc = "MkdpOpenInWindowsBrowser"
	end,
	keys = {
		{ "<leader>pm", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Markdown preview (toggle)" },
	},
}

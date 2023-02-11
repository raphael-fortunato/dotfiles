local actions = require("telescope.actions")

-- require "telescope.builtin".file_browser { cwd = vim.fn.expand("%:p:h") }
require("telescope").setup({
	defaults = {
		file_sorter = require("telescope.sorters").get_fzy_sorter,
		prompt_prefix = ">",
		color_devicons = true,

		file_previer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

		mapping = {
			i = {
				["<C-x>"] = false,
				["<C-q>"] = actions.send_to_qflist,
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
	pickers = {
		buffers = {
			mappings = {
				i = {
					["<c-d>"] = actions.delete_buffer + actions.move_to_top,
					["<c-q>"] = actions.send_to_qflist,
				},
			},
		},
	},
})

require("telescope").load_extension("fzf")
local M = {}
M.search_dotfiles = function()
	require("telescope.builtin").find_files({
		prompt_title = "< Dotfiles >",
		find_command = { "config", "ls-tree", "--full-tree", "-r", "--name-only", "HEAD" },
	})
end

return M

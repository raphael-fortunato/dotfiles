return {

	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		{
			"nvim-telescope/telescope-live-grep-args.nvim",
			build = "make",
			dependencies = "nvim-telescope/telescope.nvim",
			config = function()
				require("telescope").load_extension("live_grep_args")
			end,
		},
	},

	config = function()
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local lga_actions = require("telescope-live-grep-args.actions")

		local pickers = {
			builtin.live_grep_args,
			builtin.find_files,
			builtin.buffers,
			index = 1,
		}

		pickers.cycle = function()
			pickers[pickers.index % #pickers]({ default_text = require("telescope.actions.state").get_current_line() })
			pickers.index = pickers.index + 1
		end

		pickers.close = function(prompt_bufnr)
			pickers.index = 1
			actions.close(prompt_bufnr)
		end

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
						["<C-i>"] = actions.cycle_history_next,
						["<C-f>"] = pickers.cycle,
						["<C-o>"] = actions.cycle_history_prev,
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
				live_grep_args = {
					auto_quoting = true, -- enable/disable auto-quoting
					-- define mappings, e.g.
					mappings = { -- extend mappings
						i = {
							["<C-k>"] = lga_actions.quote_prompt(),
						},
					},
				},
			},
			pickers = {
				find_files = {
					mappings = {
						i = {
							["<C-h>"] = function(prompt_bufnr)
								local action_state = require("telescope.actions.state")
								local current_picker = action_state.get_current_picker(prompt_bufnr)
								local opts = current_picker.finder.command_generator and current_picker.finder.command_generator[1] or {}
								
								-- Toggle hidden files
								local new_opts = vim.deepcopy(opts)
								if opts.hidden then
									new_opts.hidden = false
									new_opts.no_ignore = false
								else
									new_opts.hidden = true
									new_opts.no_ignore = true
								end
								
								-- Restart the picker with new options
								actions.close(prompt_bufnr)
								require("telescope.builtin").find_files(new_opts)
							end,
						},
					},
					hidden = false,
					no_ignore = false,
				},
				buffers = {
					mappings = {
						i = {
							["<C-d>"] = actions.delete_buffer,
							["<C-q>"] = actions.send_to_qflist,
						},
					},
				},
			},
		})

		require("telescope").load_extension("live_grep_args")
		require("telescope").load_extension("fzf")
		
		local M = {}
		
		-- Track hidden files state
		local show_hidden = false
		
		M.toggle_hidden_files = function()
			show_hidden = not show_hidden
			require("telescope.builtin").find_files({
				hidden = show_hidden,
				no_ignore = show_hidden,
				prompt_title = show_hidden and "< Find Files (Hidden) >" or "< Find Files >",
			})
		end
		
		M.find_files_with_hidden = function()
			require("telescope.builtin").find_files({
				hidden = true,
				no_ignore = true,
				prompt_title = "< Find Files (Hidden) >",
			})
		end
		
		M.search_dotfiles = function()
			require("telescope.builtin").find_files({
				prompt_title = "< Dotfiles >",
				find_command = { "config", "ls-tree", "--full-tree", "-r", "--name-only", "HEAD" },
			})
		end
		
		M.find_git_changed_files = function()
			local git_cmd = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")
			if vim.v.shell_error ~= 0 then
				vim.notify("Not in a git repository", vim.log.levels.ERROR)
				return
			end
			
			local git_root = git_cmd[1]
			if not git_root or git_root == "" then
				vim.notify("Could not find git root", vim.log.levels.ERROR)
				return
			end
			
			-- Get the default branch (usually main or master)
			local default_branch_cmd = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'")
			local default_branch = "main" -- fallback
			if #default_branch_cmd > 0 and default_branch_cmd[1] ~= "" then
				default_branch = default_branch_cmd[1]
			else
				-- Try to detect main vs master
				local main_exists = vim.fn.system("git show-ref --verify --quiet refs/heads/main")
				if vim.v.shell_error == 0 then
					default_branch = "main"
				else
					default_branch = "master"
				end
			end
			
			-- Get current branch
			local current_branch_cmd = vim.fn.systemlist("git branch --show-current")
			local current_branch = current_branch_cmd[1] or "HEAD"
			
			-- Get changed files compared to default branch
			local git_files_cmd = string.format("git diff --name-only %s...%s", default_branch, current_branch)
			local changed_files = vim.fn.systemlist(git_files_cmd)
			
			if vim.v.shell_error ~= 0 or #changed_files == 0 then
				-- Fallback: get uncommitted changes
				local uncommitted_cmd = "git diff --name-only HEAD"
				changed_files = vim.fn.systemlist(uncommitted_cmd)
				
				if #changed_files == 0 then
					vim.notify("No changed files found in current branch", vim.log.levels.WARN)
					return
				end
			end
			
			-- Filter out deleted files and make paths absolute
			local existing_files = {}
			for _, file in ipairs(changed_files) do
				local full_path = git_root .. "/" .. file
				if vim.fn.filereadable(full_path) == 1 then
					table.insert(existing_files, full_path)
				end
			end
			
			if #existing_files == 0 then
				vim.notify("No existing changed files found", vim.log.levels.WARN)
				return
			end
			
			require("telescope.pickers").new({}, {
				prompt_title = string.format("< Changed Files (%s) >", current_branch),
				finder = require("telescope.finders").new_table({
					results = existing_files,
					entry_maker = function(entry)
						-- Make the display path relative to git root for readability
						local relative_path = vim.fn.fnamemodify(entry, ":." .. git_root)
						return {
							value = entry,
							display = relative_path,
							ordinal = relative_path,
							path = entry,
						}
					end,
				}),
				sorter = require("telescope.config").values.file_sorter({}),
				previewer = require("telescope.config").values.file_previewer({}),
				attach_mappings = function(prompt_bufnr, map)
					require("telescope.actions").select_default:replace(function()
						require("telescope.actions").close(prompt_bufnr)
						local selection = require("telescope.actions.state").get_selected_entry()
						vim.cmd("edit " .. selection.value)
					end)
					return true
				end,
			}):find()
		end
		
		-- Expose functions globally for easy keymap access
		_G.telescope_toggle_hidden = M.toggle_hidden_files
		_G.telescope_find_hidden = M.find_files_with_hidden
		_G.telescope_git_changed = M.find_git_changed_files
	end,
}

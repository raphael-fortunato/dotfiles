local worktree = require("git-worktree")
worktree.setup({
	change_directory_command = "cd",
	update_on_change = true,
	update_on_change_command = "e .",
	clearjumps_on_change = true,
	autopush = false,
})
-- op = Operations.Switch, Operations.Create, Operations.Delete
-- metadata = table of useful values (structure dependent on op)
--      Switch
--          path = path you switched to
--          prev_path = previous worktree path
--      Create
--          path = path where worktree created
--          branch = branch name
--          upstream = upstream remote name
--      Delete
--          path = path where worktree deleted
local send_commands = function(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local get_panes = function()
	local panes = send_commands("tmux list-panes")
	local split_panes = vim.split(panes, "\n")
	return split_panes
end

worktree.on_tree_change(function(op, metadata)
	if op == worktree.Operations.Create or op == worktree.Operations.Switch then
		if vim.fn.input("Switch other panes? (y/n):") == "y" then
			local panes = get_panes()
			local cd_cmd = "cd " .. metadata.path
			for _, pane in pairs(panes) do
				if not string.find(pane, "(active)") then
					local pane_num = tonumber(string.sub(pane, 1, 1))
					os.execute("tmux send-keys -t " .. pane_num .. ' "' .. cd_cmd .. '" Enter')
				end
			end
			print("Switched from to " .. metadata.path)
		end
	end
	if op == worktree.Operations.Create and string.find(metadata.path, "simplicity") then
		os.execute("cp ~/work/scripts/pyrightconfig.json " .. metadata.path)
		os.execute("cp ~/work/scripts/tmuxinator.yml " .. metadata.path)
		os.execute('tmux send-keys -t 1 "inc/install.sh && inc/build_dds.sh" Enter')
		os.execute("ls -sfr " .. metadata.path .. "/venv" .. " /home/raphael/venv")
	end
end)

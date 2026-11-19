-- Typst preview in zathura: `typst watch` rewrites a PDF, zathura reloads it.
local jobs = {} -- main file -> { watch = job id, viewer = job id }

local function main_file()
	local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	local found = vim.fs.find("main.typ", { upward = true, path = dir })[1]
	return found or vim.api.nvim_buf_get_name(0)
end

local function stop(main)
	local j = jobs[main]
	if not j then
		return
	end
	vim.fn.jobstop(j.watch)
	vim.fn.jobstop(j.viewer)
	jobs[main] = nil
end

local function start()
	local main = main_file()
	if jobs[main] then
		return vim.notify("Typst zathura preview already running")
	end
	local out_dir = vim.fn.stdpath("cache") .. "/typst-zathura"
	vim.fn.mkdir(out_dir, "p")
	local pdf = out_dir .. "/" .. vim.fn.sha256(main):sub(1, 8) .. ".pdf"
	local root = vim.fs.dirname(main)

	-- The tno-report package bundles Arial; without it the cover text vanishes.
	local fonts = vim.fn.glob(vim.fn.expand("~/.local/share/typst/packages/local/tno-report/*/src/assets/share/fonts"), false, true)
	local env = {}
	if vim.env.TYPST_FONT_PATHS == nil and #fonts > 0 then
		env.TYPST_FONT_PATHS = fonts[#fonts]
	end

	local watch = vim.fn.jobstart({ "typst", "watch", "--root", root, main, pdf }, { cwd = root, env = env })
	local viewer = vim.fn.jobstart({ "sh", "-c", "while [ ! -f " .. vim.fn.shellescape(pdf) .. " ]; do sleep 0.2; done; exec zathura " .. vim.fn.shellescape(pdf) }, {
		on_exit = function()
			vim.schedule(function()
				stop(main)
			end)
		end,
	})
	jobs[main] = { watch = watch, viewer = viewer }
	vim.notify("Typst zathura preview: " .. vim.fn.fnamemodify(main, ":~:."))
end

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		for main in pairs(jobs) do
			stop(main)
		end
	end,
})

return {
	{
		"neovim/nvim-lspconfig",
		opts = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "typst",
				callback = function(ev)
					vim.keymap.set("n", "<leader>cz", start, { buffer = ev.buf, desc = "Typst preview (zathura)" })
					vim.keymap.set("n", "<leader>cZ", function()
						stop(main_file())
					end, { buffer = ev.buf, desc = "Stop Typst zathura preview" })
				end,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{ "<leader>cp", icon = { icon = "󰈙", color = "azure" } },
				{ "<leader>cz", icon = { icon = "", color = "azure" } },
				{ "<leader>cZ", icon = { icon = "", color = "red" } },
				{ "<leader>cP", icon = { icon = "󰐃", color = "azure" } },
			},
		},
	},
	{
		"chomosuke/typst-preview.nvim",
		opts = {
			-- Windows Brave rather than a WSL browser; localhost is forwarded to WSL
			-- the tno-report package bundles Arial; without it the text is missing
			extra_args = function()
				local fonts = vim.fn.glob(vim.fn.expand("~/.local/share/typst/packages/local/tno-report/*/src/assets/share/fonts"), false, true)
				if vim.env.TYPST_FONT_PATHS == nil and #fonts > 0 then
					return { "--font-path=" .. fonts[#fonts] }
				end
			end,
			open_cmd = "'/mnt/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe' %s",
		},
	},
}

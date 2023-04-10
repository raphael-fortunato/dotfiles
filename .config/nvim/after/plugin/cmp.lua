-- Setup nvim-cmp.
local cmp = require("cmp")
cmp.setup({
	mapping = {
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-e>"] = cmp.mapping.abort(),
		["<c-y>"] = cmp.mapping(
			cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = true,
			}),
			{ "i", "c" }
		),

		["<c-space>"] = cmp.mapping({
			i = cmp.mapping.complete(),
			c = function(
				_ --[[fallback]]
			)
				if cmp.visible() then
					if not cmp.confirm({ select = true }) then
						return
					end
				else
					cmp.complete()
				end
			end,
		}),

		["<tab>"] = cmp.config.disable,

		["<c-q>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
	},

	sources = {
		-- { name = "gh_issues" },

		-- Youtube: Could enable this only for lua, but nvim_lua handles that already.
		{ name = "path" },
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_length = 3 },
		{ name = "nvim_lua" },
		{ name = "zsh" },
		{ name = "spell" },
	},
	-- Set configuration for specific filetype.
	cmp.setup.filetype("cucumber", {
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			-- { name = "behave" },
		}, { name = "buffer", keyword_length = 3 }),
	}),

	-- Youtube: mention that you need a separate snippets plugin
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	window = {
		documentation = {
			border = "rounded",
			max_height = 15,
			max_width = 50,
			zindex = 50,
		},
	},
	formatting = {
		fields = { "abbr", "kind", "menu" },
		format = function(entry, item)
			local menu_icon = {
				behave = "[BHAVE]",
				nvim_lsp = "[LSP]",
				luasnip = "[SNIP]",
				buffer = "[BUF]",
				path = "[PATH]",
				nvim_lua = "[LUA]",
				spell = "[SPELL]",
			}

			item.menu = menu_icon[entry.source.name]
			return item
		end,
	},
	experimental = {
		-- I like the new menu better! Nice work hrsh7th
		native_menu = false,

		-- Let's play with this for a day or two
		ghost_text = true,
	},
})

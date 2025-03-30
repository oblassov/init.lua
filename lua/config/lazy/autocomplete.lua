return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim API
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	{ "Bilal2453/luvit-meta", lazy = true },
	{

		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					-- See the README about individual language/framework/plugin snippets:
					-- https://github.com/rafamadriz/friendly-snippets
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
				config = function()
					local ls = require("luasnip")
					ls.filetype_extend("javascript", { "jsdoc" })
				end,
			},
			"saadparwaiz1/cmp_luasnip",
			-- Adds other completion capabilities.
			-- nvim-cmp does not ship with all sources by default. They are split
			-- into multiple repos for maintenance purposes.
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})
			local cmp_select = { behavior = cmp.SelectBehavior.Select }
			cmp.setup({
				-- Enable luasnip to handle snippet expansion for nvim-cmp
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				completion = { completeopt = "menu,menuone,noselect" },
				sources = {
					{ name = "path" },
					{
						name = "nvim_lsp",
						keyword_length = 1,
						option = {
							markdown_oxide = {
								keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
							},
						},
					},
					{ name = "luasnip", keyword_length = 2 },
					{ name = "buffer", keyword_length = 3 },
					{
						name = "lazydev",
						-- Set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
				},
				window = {
					documentation = cmp.config.window.bordered({ border = "single" }),
				},
				formatting = {
					expandable_indicator = true,
					fields = { "menu", "abbr", "kind" },
					format = function(entry, item)
						local menu_icon = {
							nvim_lsp = "λ",
							luasnip = "⋗",
							buffer = "Ω",
							path = "🖫",
							cmdline = ":",
						}
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-e>"] = cmp.mapping.abort(),
					-- Scroll docs while selecting autocomplete entry not while hover
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					-- Generally unneeded as nvim-cmp displays completions upon ready
					--["<C-Space>"] = cmp.mapping(
					--	cmp.mapping.complete({
					--		reason = cmp.ContextReason.Auto, --or *.Manual
					--	}),
					--	{ "i", "c" }
					--),
					["<C-j>"] = cmp.mapping(function(fallback)
						if luasnip.expand_or_locally_jumpable(1) then
							luasnip.expand_or_jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-k>"] = cmp.mapping(function(fallback)
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-l>"] = cmp.mapping(function(fallback)
						if luasnip.choice_active() then
							luasnip.change_choice(1)
						else
							fallback()
						end
					end, { "i" }),
					-- Config for tab navigation for those who prefer that

					--["<Tab>"] = cmp.mapping(function(fallback)
					--	local col = vim.fn.col(".") - 1
					--	if cmp.visible() then
					--		cmp.select_next_item(cmp_select)
					--	elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
					--		fallback()
					--	else
					--		cmp.complete()
					--	end
					--end, { "i", "s" }),
					--
					--["<S-Tab>"] = cmp.mapping(function(fallback)
					--	if cmp.visible() then
					--		cmp.select_prev_item(cmp_select)
					--	else
					--		fallback()
					--	end
					--end, { "i", "s" }),
				}),
			})

			-- Set up completion for command line
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "cmdline" },
					{ name = "path" },
				},
			})

			-- Set up completion for search
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},
}

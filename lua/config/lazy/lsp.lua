return {

	{ -- LSP Plugins
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim API
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},

	{ "Bilal2453/luvit-meta", lazy = true },

	{ -- Main LSP Configuration
		"neovim/nvim-lspconfig",

		dependencies = {

			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},

		config = function()
			-- Passing some arguments for clangd to see standard libraries headers
			--local handle = io.popen("command -v ucrt64")
			--local compiler
			--if handle then
			--	compiler = handle:read("*a"):sub(1, -2)
			--	handle:close()
			--else
			--	compiler = nil
			--end

			local sign = function(opts)
				vim.fn.sign_define(opts.name, {
					texthl = opts.name,
					text = opts.text,
					numhl = "",
				})
			end

			sign({ name = "DiagnosticSignError", text = "✘" })
			sign({ name = "DiagnosticSignWarn", text = "▲" })
			sign({ name = "DiagnosticSignHint", text = "⚑" })
			sign({ name = "DiagnosticSignInfo", text = "»" })

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })

			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })

			vim.diagnostic.config({
				-- update_in_insert = true,
				virtual_text = true,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "single",
					source = "if_many",
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("config-group-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press "<C-t>".
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Help with function signatures
					map("gs", vim.lsp.buf.signature_help, "[G]oto [S]ignature")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					--if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
					--	local highlight_augroup = vim.api.nvim_create_augroup("config-group-highlight", { clear = false })
					--	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					--		buffer = event.buf,
					--		group = highlight_augroup,
					--		callback = vim.lsp.buf.document_highlight,
					--	})
					--
					--	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					--		buffer = event.buf,
					--		group = highlight_augroup,
					--		callback = vim.lsp.buf.clear_references,
					--	})
					--
					--	vim.api.nvim_create_autocmd("LspDetach", {
					--		group = vim.api.nvim_create_augroup("config-group-detach", { clear = true }),
					--		callback = function(event2)
					--			vim.lsp.buf.clear_references()
					--			vim.api.nvim_clear_autocmds({
					--				group = "config-group-highlight",
					--				buffer = event2.buf,
					--			})
					--		end,
					--	})
					--end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
								bufnr = event.buf,
							}))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

			local servers = {

				ast_grep = {},

				--clangd = {
				--	capabilities = capabilities,
				--	cmd = { vim.fn.stdpath("data") .. "/mason/bin/clangd", compiler and "--query-driver=" .. compiler },
				--	filetypes = { "c", "cpp", "h", "hpp", "inl", "objc", "objcpp", "cuda", "proto" },
				--},

				--pyright = {},
				--
				--rust_analyzer = {},
				--
				--... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				--Some languages (like typescript) have entire language plugins that can be useful:
				--https://github.com/pmizio/typescript-tools.nvim
				--But for many setups, the LSP (`tsserver`) will work just fine:
				--
				--tsserver = {},

				harper_ls = {
					settings = {
						["harper-ls"] = {
							userDictPath = "~/AppData/Roaming/harper-ls/dict.txt",
							linters = {
								spell_check = true,
								spelled_numbers = false,
								an_a = true,
								sentence_capitalization = false,
								unclosed_quotes = true,
								wrong_quotes = false,
								long_sentences = true,
								repeated_words = true,
								spaces = true,
								matcher = true,
								correct_number_suffix = true,
								number_suffix_capitalization = true,
								multiple_sequential_pronouns = true,
								linking_verbs = false,
								avoid_curses = false,
							},
							diagnosticSeverity = "hint", -- Can be "hint", "information", "warning", or "error"
							codeActions = {
								forceStable = true,
							},
						},
					},
				},

				gopls = {
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
					root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
					settings = {
						gopls = {
							gofumpt = false,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								fieldalignment = true,
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = {
								"-.git",
								"-.vscode",
								"-.idea",
								"-.vscode-test",
								"-node_modules",
								"-.nvim",
							},
							semanticTokens = true,
						},
					},
				},

				templ = {},

				html = {
					filetypes = { "html", "templ" },
				},

				jdtls = {},

				markdown_oxide = {

					-- Ensure that dynamicRegistration is enabled! This allows the LS to take into account actions like the
					-- Create Unresolved File code action, resolving completions for unindexed code blocks, ...
					capabilities = vim.tbl_deep_extend("force", capabilities, {
						workspace = {
							didChangeWatchedFiles = {
								dynamicRegistration = true,
							},
						},
					}),
				},

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
							diagnostics = {
								globals = {
									"bit",
									"vim",
									"it",
									"describe",
									"before_each",
									"after_each",
								},
							},
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})

			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ --Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local disable_filetypes = { c = true, cpp = true }
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return {
					timeout_ms = 500,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofmt" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*", -- Replace "<CurrentMajor>" by the latest released major (first number of latest release)
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
		},

		config = function()
			vim.opt.completeopt = { "menu", "menuone", "noselect" }

			local cmp = require("cmp")
			local luasnip = require("luasnip")

			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			cmp.setup({

				-- Enable luasnip to handle snippet expansion for nvim-cmp

				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- For `luasnip` users.
					end,
				},

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
					documentation = cmp.config.window.bordered(),
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
		end,
	},
}

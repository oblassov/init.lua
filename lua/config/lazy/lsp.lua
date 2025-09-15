return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
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

				local _border = "single"

				local function bordered_hover(_opts)
					_opts = _opts or {}
					return vim.lsp.buf.hover(vim.tbl_deep_extend("force", _opts, {
						border = _border,
					}))
				end

				-- Displays hover information about the symbol under the cursor in a floating
				--  window. The window will be dismissed on cursor move.
				map("K", bordered_hover, "Hover over the symbol")

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

				local function bordered_signature_help(_opts)
					_opts = _opts or {}
					return vim.lsp.buf.signature_help(vim.tbl_deep_extend("force", _opts, {
						border = _border,
					}))
				end

				-- Help with function signatures
				map("gs", bordered_signature_help, "[G]oto [S]ignature")

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
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

				local function client_supports_method(client, method, bufnr)
					return client:supports_method(method, bufnr)
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				-- See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).

				-- if
				-- 	client
				-- 	and client_supports_method(
				-- 		client,
				-- 		vim.lsp.protocol.Methods.textDocument_documentHighlight,
				-- 		event.buf
				-- 	)
				-- then
				-- 	local highlight_augroup = vim.api.nvim_create_augroup("config-group-highlight", { clear = false })
				-- 	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				-- 		buffer = event.buf,
				-- 		group = highlight_augroup,
				-- 		callback = vim.lsp.buf.document_highlight,
				-- 	})
				--
				-- 	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				-- 		buffer = event.buf,
				-- 		group = highlight_augroup,
				-- 		callback = vim.lsp.buf.clear_references,
				-- 	})
				--
				-- 	vim.api.nvim_create_autocmd("LspDetach", {
				-- 		group = vim.api.nvim_create_augroup("config-group-detach", { clear = true }),
				-- 		callback = function(event2)
				-- 			vim.lsp.buf.clear_references()
				-- 			vim.api.nvim_clear_autocmds({
				-- 				group = "config-group-highlight",
				-- 				buffer = event2.buf,
				-- 			})
				-- 		end,
				-- 	})
				-- end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code
				if
					client
					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
				then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- Diagnostic Config
		-- See :help vim.diagnostic.Opts
		vim.diagnostic.config({
			severity_sort = true,

			float = {
				focusable = true,
				style = "minimal",
				border = "single",
				source = "if_many",
			},

			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = true,
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
			virtual_lines = {
				current_line = true,
			},
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

			-- clangd = {},
			-- pyright = {},
			-- rust_analyzer = {},
			-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
			--
			-- Some languages (like typescript) have entire language plugins that can be useful:
			--    https://github.com/pmizio/typescript-tools.nvim
			--
			-- But for many setups, the LSP (`ts_ls`) will work just fine
			-- ts_ls = {},
			--

			gopls = {
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_dir = require("lspconfig/util").root_pattern("go.work", "go.mod", ".git"),
				settings = {
					gopls = {
						gofumpt = false,
						codelenses = {
							gc_details = true,
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

			golangci_lint_ls = {
				cmd = { "golangci-lint-langserver" },
				filetypes = { "go" },
				init_options = {
					command = {
						"golangci-lint",
						"run",
						"--output.json.path",
						"stdout",
						"--show-stats=false",
						"--issues-exit-code=1",
					},
				},
				root_dir = function(fname)
					return require("lspconfig/util").root_pattern(
						".golangci.yml",
						".golangci.yaml",
						".golangci.toml",
						".golangci.json",
						"go.mod",
						"go.work",
						".git"
					)(fname)
				end,
				on_new_config = function(new_config, root_dir)
					local global_config_path = vim.env.HOME .. "/.config/golangci-lint/.golangci.yml"
					local project_config_paths = {
						root_dir .. "/.golangci.yml",
						root_dir .. "/.golangci.yaml",
						root_dir .. "/.golangci.toml",
						root_dir .. "/.golangci.json",
					}

					-- Check for project-specific configs
					for _, config_path in ipairs(project_config_paths) do
						if vim.fn.filereadable(config_path) == 1 then
							local command = vim.deepcopy(new_config.init_options.command)
							table.insert(command, "--config")
							table.insert(command, config_path)
							new_config.init_options.command = command
							vim.notify("golangci_lint_ls: using project config at " .. config_path, vim.log.levels.INFO)
							return
						end
					end

					-- If no project config, check for global config
					if vim.fn.filereadable(global_config_path) == 1 then
						local command = vim.deepcopy(new_config.init_options.command)
						table.insert(command, "--config")
						table.insert(command, global_config_path)
						new_config.init_options.command = command
						vim.notify(
							"golangci_lint_ls: using global config at " .. global_config_path,
							vim.log.levels.INFO
						)
						return
					end

					-- Fallback: no changes to command, use default
					vim.notify("golangci_lint_ls: using default config", vim.log.levels.INFO)
				end,
			},

			html = {
				filetypes = { "html", "templ" },
			},

			templ = {},

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

			stylua = {}, -- Used to format Lua code

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
						hint = {
							enable = true,
							setType = false,
							paramType = true,
							paramName = "Disable",
							semicolon = "Disable",
							arrayIndex = "Disable",
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

		---@diagnostic disable-next-line: missing-fields
		require("mason").setup({
			ui = {
				border = "single",
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
			-- "golangci-lint", -- Golang Linters
		})

		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		---@diagnostic disable-next-line: missing-fields
		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for ts_ls)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}

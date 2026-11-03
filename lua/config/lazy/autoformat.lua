return {
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
			if disable_filetypes[vim.bo[bufnr].filetype] then
				return nil
			else
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			-- golangci-lint fmt applies the project's .golangci.yml formatters (gofumpt, goimports),
			-- the same formatting Claude's lint hook applies; plain gofmt when golangci-lint is missing
			go = { "golangci-lint", "gofmt", stop_after_first = true },
			-- Ruff: sort imports, then format (reads ruff.toml / pyproject.toml)
			python = { "ruff_organize_imports", "ruff_format" },
			-- Prettier from the project's node_modules; LSP formatting when the project has none
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
		},
		formatters = {
			["golangci-lint"] = {
				-- `fmt --stdin` only finds .golangci.yml when run from the project directory
				cwd = function(self, ctx)
					return require("conform.util").root_file({
						".golangci.yml",
						".golangci.yaml",
						".golangci.toml",
						".golangci.json",
						"go.mod",
					})(self, ctx)
				end,
			},
		},
	},
}

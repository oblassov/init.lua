return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	build = ":TSUpdate",
	config = function()
		-- Compatibility shim for Neovim 0.12+ quantified captures in treesitter directives
		local query = require("vim.treesitter.query")
		local function first_node(node)
			if type(node) == "table" then
				return node[1]
			end
			return node
		end

		query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
			local id = pred[2]
			local node = first_node(match[id])
			if not node then
				return
			end
			local alias = vim.treesitter.get_node_text(node, bufnr):lower()
			local match_ft = vim.filetype.match({ filename = "a." .. alias })
			metadata["injection.language"] = match_ft or alias
		end, { force = true })

		require("nvim-treesitter.install").prefer_git = false
		require("nvim-treesitter.install").compilers = { "clang", "gcc" }

		require("nvim-treesitter.configs").setup({

			-- A list of parser names, or "all"
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"go",
				"templ",
				"rust",
				"java",
				"json",
				"jsdoc",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"html",
				"yaml",
				"markdown",
				"markdown_inline",
				"sql",
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			indent = {
				enable = true,
				disable = { "yaml" },
			},

			highlight = {
				-- `false` will disable the whole extension
				enable = true,

				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = { "markdown" },
			},

			ignore_install = {},
			modules = {},
		})
	end,
}

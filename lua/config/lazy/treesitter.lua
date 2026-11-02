return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- Upstream mainline (master is frozen); requires nvim 0.12+ and tree-sitter CLI
	lazy = false, -- main branch does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")

		-- Parsers to keep installed (install() is async and skips already-installed parsers)
		ts.install({
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
		})

		-- Enable highlighting + indentation for a buffer (replaces configs.setup highlight/indent)
		local function attach(buf, lang, ft)
			if not pcall(vim.treesitter.start, buf, lang) then
				return
			end
			if ft == "markdown" then
				vim.bo[buf].syntax = "on" -- Was additional_vim_regex_highlighting = { "markdown" }
			end
			if ft ~= "yaml" then -- Was indent.disable = { "yaml" }
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("TreesitterAttach", { clear = true }),
			callback = function(event)
				local lang = vim.treesitter.language.get_lang(event.match)
				if not lang then
					return
				end
				if vim.tbl_contains(ts.get_installed(), lang) then
					attach(event.buf, lang, event.match)
				elseif vim.tbl_contains(ts.get_available(), lang) then
					-- Was auto_install = true: install missing parser, then attach
					ts.install(lang):await(vim.schedule_wrap(function()
						if vim.api.nvim_buf_is_valid(event.buf) then
							attach(event.buf, lang, event.match)
						end
					end))
				end
			end,
		})
	end,
}

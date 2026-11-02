-- Custom Telescope extension: Live MultiGrep
-- Allows filtering text content and file paths simultaneously using a two-space delimiter.
-- Syntax: "<search pattern>  <file glob>" (e.g. "function  *.lua" or "err  !*_test.go")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local M = {}

-- Spawns an async Telescope picker with a dynamic ripgrep command generator
local live_multigrep = function(opts)
	opts = opts or {}
	opts.cwd = opts.cwd or vim.fn.getcwd()

	local finder = finders.new_async_job({
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end

			-- Delimiter: two spaces ("  ") separates content search from file glob
			local pieces = vim.split(prompt, "  ")
			local args = { "rg" }

			-- Piece 1: Search query -> converted to inline fuzzy regex pattern
			if pieces[1] then
				-- Transforms "abc" -> "[^a]*a[^b]*b[^c]*c" for regex fuzzy matching
				local fuzzy_pattern = pieces[1]:gsub(".", function(c)
					return "[^" .. c .. "]*" .. c
				end)
				table.insert(args, "-e")
				table.insert(args, fuzzy_pattern)
			end

			-- Piece 2: Optional file path / glob filter (passed to rg -g)
			if pieces[2] then
				table.insert(args, "-g")
				table.insert(args, pieces[2])
			end

			-- Ripgrep output flags required by Telescope's vimgrep entry maker
			return vim.iter({
				args,
				{
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--pcre2", -- Enable PCRE2 for regex support
				},
			})
				:flatten()
				:totable()
		end,

		entry_maker = make_entry.gen_from_vimgrep(opts),
		cwd = opts.cwd,
	})

	pickers
		.new(opts, {
			debounce = 100, -- Throttle subprocess spawning while typing (100ms)
			prompt_title = "Multi Grep (<pattern>  <glob>)",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = require("telescope.sorters").get_fuzzy_file(),
		})
		:find()
end

M.setup = function()
	vim.keymap.set("n", "<leader>ps", live_multigrep, { desc = "Telescope: live multigrep (pattern  glob)" })
end

return M

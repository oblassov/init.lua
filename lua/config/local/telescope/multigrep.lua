local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local M = {}

local live_multigrep = function(opts)
	opts = opts or {}
	opts.cwd = opts.cwd or vim.fn.getcwd()

	local finder = finders.new_async_job({
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end

			local pieces = vim.split(prompt, "  ")
			local args = { "rg" }

			if pieces[1] then
				-- Convert the search pattern to fuzzy matching pattern
				local fuzzy_pattern = pieces[1]:gsub(".", function(c)
					return "[^" .. c .. "]*" .. c
				end)
				table.insert(args, "-e")
				table.insert(args, fuzzy_pattern)
			end

			if pieces[2] then
				table.insert(args, "-g")
				table.insert(args, pieces[2])
			end

			---@diagnostic disable-next-line: deprecated
			return vim.tbl_flatten({
				args,
				{
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--pcre2", -- Enable PCRE2 for better regex support
				},
			})
		end,

		entry_maker = make_entry.gen_from_vimgrep(opts),
		cwd = opts.cwd,
	})

	pickers
		.new(opts, {
			debounce = 100,
			prompt_title = "Multi Grep",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = require("telescope.sorters").get_fuzzy_file(),
		})
		:find()
end

M.setup = function()
	vim.keymap.set("n", "<leader>ps", live_multigrep)
end

return M

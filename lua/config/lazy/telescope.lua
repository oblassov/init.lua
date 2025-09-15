return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	-- or "                             ",
	-- branch = '0.1.x',
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},

	config = function()
		require("telescope").setup({
			defaults = require("telescope.themes").get_ivy(),
			extensions = {
				fzf = {},
			},
		})

		local builtin = require("telescope.builtin")
		require("telescope").load_extension("fzf")
		require("config.local.telescope.multigrep").setup()

		vim.keymap.set("n", "<leader>pf", builtin.find_files)

		vim.keymap.set("n", "<C-p>", function()
			local path = vim.fn.expand("%:p:h") -- Get current directory

			-- Check if we're in a git repo using Neovim's system functions
			local handle = vim.fn.jobstart({ "git", "-C", path, "rev-parse", "--is-inside-work-tree" }, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if data and data[1] == "true" then
						builtin.git_files({ cwd = path }, { use_git_root = true })
					else
						builtin.find_files()
					end
				end,
			})

			-- Fallback if job fails to start
			if handle <= 0 then
				builtin.find_files()
			end
		end, { desc = "Open git files if inside a repo" })

		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)

		vim.keymap.set("n", "<leader>fh", builtin.help_tags)

		vim.keymap.set("n", "<leader>fn", function()
			---@diagnostic disable-next-line: param-type-mismatch
			builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
		end)

		vim.keymap.set("n", "<leader>cn", function()
			builtin.find_files({
				cwd = vim.fn.stdpath("config"),
			})
		end)

		-- Basic Harpoon configuration
		local harpoon = require("harpoon")
		harpoon:setup({})

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}

			for _, item in ipairs(harpoon_files.items) do
				vim.list.extend(file_paths, item.value)
			end

			-- Use Telescope's new picker API
			require("telescope.pickers")
				.new({
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					-- Use the new sorter API instead of deprecated generic_sorter
					sorter = require("telescope.sorters").get_fuzzy_file(),
					-- Alternatively, use the generic sorter if you need fuzzy matching:
					-- sorter = require("telescope.sorters").get_generic_fuzzy_sorter({}),
				}, {})
				:find()
		end
		vim.keymap.set("n", "<leader>ph", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon window" })
	end,
}

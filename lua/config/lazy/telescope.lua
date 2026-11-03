return {
	-- Telescope: Fuzzy finder over files, git, symbols, and plugins
	"nvim-telescope/telescope.nvim",
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

		-- File search pickers
		vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files in project" })

		vim.keymap.set("n", "<C-p>", function()
			local path = vim.fn.expand("%:p:h") -- Get current directory

			-- Check if we're in a git repo using Neovim's system functions
			local handle = vim.fn.jobstart({ "git", "-C", path, "rev-parse", "--is-inside-work-tree" }, {
				stdout_buffered = true,
				on_stdout = function(_, data)
					if data and data[1] == "true" then
						builtin.git_files({ cwd = path, use_git_root = true })
					else
						builtin.find_files()
					end
				end,
			})

			-- Fallback if job fails to start
			if handle <= 0 then
				builtin.find_files()
			end
		end, { desc = "Find git files (fallback to find_files)" })

		-- Grep pickers under cursor
		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end, { desc = "Grep word under cursor" })

		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end, { desc = "Grep WORD under cursor" })

		-- Help & config navigation
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Search help documentation tags" })

		vim.keymap.set("n", "<leader>fn", function()
			---@diagnostic disable-next-line: param-type-mismatch
			builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
		end, { desc = "Find Neovim plugin files" })

		vim.keymap.set("n", "<leader>cn", function()
			builtin.find_files({
				cwd = vim.fn.stdpath("config"),
			})
		end, { desc = "Find Neovim config files" })

		-- Harpoon picker integration
		local harpoon = require("harpoon")

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}

			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			-- Use Telescope's new picker API
			require("telescope.pickers")
				.new({
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = require("telescope.sorters").get_fuzzy_file(),
				}, {})
				:find()
		end
		vim.keymap.set("n", "<leader>ph", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open Harpoon list in Telescope" })
	end,
}

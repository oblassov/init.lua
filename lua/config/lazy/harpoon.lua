return {
	-- Harpoon 2: Quick file pinning and home-row buffer navigation
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		-- List management
		vim.keymap.set("n", "<leader>H", function()
			harpoon:list():prepend()
		end, { desc = "Harpoon: prepend file to list" })
		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():add()
		end, { desc = "Harpoon: append file to list" })
		vim.keymap.set("n", "<C-h>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: toggle quick menu" })

		-- Direct slot navigation (slots 1-6)
		vim.keymap.set("n", "<C-f>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: jump to slot 1" })
		vim.keymap.set("n", "<C-d>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: jump to slot 2" })
		vim.keymap.set("n", "<C-s>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: jump to slot 3" })
		vim.keymap.set("n", "<C-v>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: jump to slot 4" })
		vim.keymap.set("n", "<C-c>", function()
			harpoon:list():select(5)
		end, { desc = "Harpoon: jump to slot 5" })
		vim.keymap.set("n", "<C-x>", function()
			harpoon:list():select(6)
		end, { desc = "Harpoon: jump to slot 6" })

		-- Replace slot with current buffer (slots 1-6)
		vim.keymap.set("n", "<leader><C-f>", function()
			harpoon:list():replace_at(1)
		end, { desc = "Harpoon: replace slot 1 with current file" })
		vim.keymap.set("n", "<leader><C-d>", function()
			harpoon:list():replace_at(2)
		end, { desc = "Harpoon: replace slot 2 with current file" })
		vim.keymap.set("n", "<leader><C-s>", function()
			harpoon:list():replace_at(3)
		end, { desc = "Harpoon: replace slot 3 with current file" })
		vim.keymap.set("n", "<leader><C-v>", function()
			harpoon:list():replace_at(4)
		end, { desc = "Harpoon: replace slot 4 with current file" })
		vim.keymap.set("n", "<leader><C-c>", function()
			harpoon:list():replace_at(5)
		end, { desc = "Harpoon: replace slot 5 with current file" })
		vim.keymap.set("n", "<leader><C-x>", function()
			harpoon:list():replace_at(6)
		end, { desc = "Harpoon: replace slot 6 with current file" })
	end,
}

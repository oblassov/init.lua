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
		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: jump to slot 1" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: jump to slot 2" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: jump to slot 3" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: jump to slot 4" })
		vim.keymap.set("n", "<leader>5", function()
			harpoon:list():select(5)
		end, { desc = "Harpoon: jump to slot 5" })
		vim.keymap.set("n", "<leader>6", function()
			harpoon:list():select(6)
		end, { desc = "Harpoon: jump to slot 6" })

		-- Replace slot with current buffer (slots 1-6)
		vim.keymap.set("n", "<leader><C-1>", function()
			harpoon:list():replace_at(1)
		end, { desc = "Harpoon: replace slot 1 with current file" })
		vim.keymap.set("n", "<leader><C-2>", function()
			harpoon:list():replace_at(2)
		end, { desc = "Harpoon: replace slot 2 with current file" })
		vim.keymap.set("n", "<leader><C-3>", function()
			harpoon:list():replace_at(3)
		end, { desc = "Harpoon: replace slot 3 with current file" })
		vim.keymap.set("n", "<leader><C-4>", function()
			harpoon:list():replace_at(4)
		end, { desc = "Harpoon: replace slot 4 with current file" })
		vim.keymap.set("n", "<leader><C-5>", function()
			harpoon:list():replace_at(5)
		end, { desc = "Harpoon: replace slot 5 with current file" })
		vim.keymap.set("n", "<leader><C-6>", function()
			harpoon:list():replace_at(6)
		end, { desc = "Harpoon: replace slot 6 with current file" })
	end,
}

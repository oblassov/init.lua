return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		vim.keymap.set("n", "<leader>h", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "<C-h>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)

		vim.keymap.set("n", "<C-a>", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<C-s>", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<C-d>", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<C-f>", function()
			harpoon:list():select(4)
		end)
		vim.keymap.set("n", "<C-g>", function()
			harpoon:list():select(5)
		end)

		vim.keymap.set("n", "<leader><C-a>", function()
			harpoon:list():replace_at(1)
		end)
		vim.keymap.set("n", "<leader><C-s>", function()
			harpoon:list():replace_at(2)
		end)
		vim.keymap.set("n", "<leader><C-d>", function()
			harpoon:list():replace_at(3)
		end)
		vim.keymap.set("n", "<leader><C-f>", function()
			harpoon:list():replace_at(4)
		end)
		vim.keymap.set("n", "<leader><C-g>", function()
			harpoon:list():replace_at(5)
		end)
	end,
}

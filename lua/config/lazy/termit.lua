return {
	require("config.local.termit").setup({
		-- Optional: customize keymaps
		keymaps = {
			toggle_terminal = "<C-\\>",
			toggle_lazygit = "<leader>lg",
			hide_terminal = "<C-]>",
		},
		floating = {
			width = 0.95,
			height = 1,
			cliapp = "lazygit",
			border = "rounded",
		},
		side_term = {
			width = 0.34,
			height = 0.34,
		},
	}),
}

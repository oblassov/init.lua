return {
	-- Indent-blankline: Visual indentation guides and active scope indicators
	"lukas-reineke/indent-blankline.nvim",
	version = "*", -- Track latest stable semver release
	event = { "BufReadPost", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "┊",
			tab_char = "┊",
		},
		scope = {
			enabled = true,
			show_start = true,
			show_end = true,
		},
	},
}

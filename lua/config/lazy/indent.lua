return {
	-- Indent-blankline: Visual indentation guides and active scope indicators
	"lukas-reineke/indent-blankline.nvim",
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

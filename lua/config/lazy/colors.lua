function ColorMyPencils(color)
	color = color or "tokyonight-day" -- change the colorscheme of the selected theme, to change the theme place ColorMyPencils function in the config function
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#EEF1F9" })
end

return {
	{
		"folke/tokyonight.nvim",

		lazy = false,
		opts = {},
		config = function()
			require("tokyonight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				style = "day", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
				light_style = "day", -- The theme is used when the background is set to light
				transparent = true, -- Enable this to disable setting the background color
				terminal_colors = true, -- Configure the colors used when opening `:terminal` in Neovim
				styles = {
					-- Style to be applied to different syntax groups
					-- Value is any valid attr-list value for `:help nvim_set_hl`
					comments = { italic = false },
					keywords = { italic = false },
					functions = {},
					variables = {},
					-- Background styles. Can be "dark", "transparent" or "normal"
					sidebars = "transparent", -- style for sidebars, see below
					floats = "transparent", -- style for floating windows
				},
				day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
				dim_inactive = true, -- dims inactive windows
				lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
			})
			ColorMyPencils()
		end,
	},
	{
		"projekt0n/github-nvim-theme",

		name = "github-theme",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins

		config = function()
			-- Default options
			require("github-theme").setup({
				options = {
					-- Compiled file's destination location
					compile_path = vim.fn.stdpath("cache") .. "/github-theme",
					compile_file_suffix = "_compiled", -- Compiled file suffix
					hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer for a cleaner look
					hide_nc_statusline = false, -- Override the underline style for non-active statuslines
					transparent = true, -- Disable setting bg (make neovim's background transparent)
					terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
					dim_inactive = false, -- Non focused panes set to alternative background
					module_default = true, -- Default enable value for modules
					styles = { -- Style to be applied to different syntax groups
						comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
						functions = "NONE",
						keywords = "NONE",
						variables = "NONE",
						conditionals = "NONE",
						constants = "NONE",
						numbers = "NONE",
						operators = "NONE",
						strings = "NONE",
						types = "NONE",
					},
					inverse = { -- Inverse highlight for different types
						match_paren = false,
						visual = false,
						search = false,
					},
					darken = { -- Darken floating windows and sidebar-like windows
						floats = true,
						sidebars = {
							enable = true,
							list = { "netrw", "terminal" }, -- Apply dark background to specific windows
						},
					},
					modules = { -- List of various plugins and additional options
						-- ...
						telescope = true,
						treesitter_context = true,
					},
				},
				palettes = {},
				specs = {},
				groups = {},
			})
		end,
	},
}

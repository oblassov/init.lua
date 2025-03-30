function _G.ColorMyPencils(color)
	color = color or "tokyonight-day" -- change the colorscheme of the selected theme, to change the theme place ColorMyPencils function in the config function
	vim.cmd.colorscheme(color)

	local highlights = {
		Pmenu = { bg = "#f1f2f7" }, -- Main completion background
		PmenuSel = { bg = "#d0d5e3" }, -- Selected item background
		Visual = { bg = "#e1e2e7" },
		VisualNC = { bg = "#e1e2e7" },
		VisualNOS = { bg = "#e1e2e7" },
		Normal = { bg = "none" },
		NormalFloat = { bg = "none" },
		TreesitterContext = { bg = "#f1f2f7" },
	}

	for group, colors in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, colors)
	end
end

vim.api.nvim_create_user_command("ColorMyPencils", function(opts)
	_G.ColorMyPencils(opts.args)
end, { nargs = "?" })

return {
	{
		"folke/tokyonight.nvim",

		lazy = false,
		opts = {},
		config = function()
			require("tokyonight").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
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
				cache = true,
			})
			ColorMyPencils() -- Call custom configuration function
		end,
	},
}

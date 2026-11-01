return {
	"mbbill/undotree",
	cmd = "UndotreeToggle",
	keys = {
		{ "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
	},
	init = function()
		-- Uncomment below to make it work in Windows. It is ok, we don't judge you.
		-- vim.g.undotree_DiffCommand = "FC"
	end,
}

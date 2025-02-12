return {
	"mbbill/undotree",

	config = function()
		-- Uncomment below to make it work in Windows. It is ok, we don't judge you.
		-- vim.g.undotree_DiffCommand = "FC"
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
	end,
}

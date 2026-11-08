return {
	-- Fugitive: Git wrapper for status, blame, diffs, and merge conflict resolution
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gt", vim.cmd.Git, { desc = "Git: open Fugitive status window" })

		local Local_Config_Fugitive = vim.api.nvim_create_augroup("Local_Config_Fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = Local_Config_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }

				-- Buffer-local git actions inside Fugitive window
				vim.keymap.set("n", "<leader>p", function()
					vim.cmd.Git("push")
				end, vim.tbl_extend("force", opts, { desc = "Git: push" }))

				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git({ "pull", "--rebase" })
				end, vim.tbl_extend("force", opts, { desc = "Git: pull --rebase" }))

				vim.keymap.set(
					"n",
					"<leader>t",
					":Git push -u origin ",
					vim.tbl_extend("force", opts, { desc = "Git: push -u origin <branch>" })
				)
			end,
		})

		-- 3-way merge conflict resolution shortcuts:
		-- <leader>gu: diffget //2 -> accept hunk from LOCAL/target branch
		-- <leader>gh: diffget //3 -> accept hunk from REMOTE/incoming branch
		vim.keymap.set("n", "<leader>gu", "<cmd>diffget //2<CR>", { desc = "Git merge: take LOCAL changes (target)" })
		vim.keymap.set(
			"n",
			"<leader>gh",
			"<cmd>diffget //3<CR>",
			{ desc = "Git merge: take REMOTE changes (incoming)" }
		)
	end,
}

return {
	-- Peek: Live markdown previewer in the browser (requires deno)
	"toppair/peek.nvim",

	event = { "VeryLazy" },
	build = "deno task --quiet build:fast",

	config = function()
		local peek = require("peek")

		peek.setup({
			auto_load = true, -- Auto-load preview when entering a markdown buffer
			close_on_bdelete = true, -- Close preview window when buffer is deleted
			syntax = true, -- Enable syntax highlighting in preview
			theme = "light", -- 'dark' or 'light'
			update_on_change = true, -- Live update as you edit
			app = "browser", -- Open preview in default web browser
			filetype = { "markdown" }, -- Filetypes to preview
			throttle_at = 200000, -- Throttle rendering on files larger than 200KB
			throttle_time = "auto",
		})

		vim.api.nvim_create_user_command("PeekOpen", function()
			if not peek.is_open() and vim.bo[vim.api.nvim_get_current_buf()].filetype == "markdown" then
				peek.open()
			end
		end, { desc = "Open markdown live preview" })

		vim.api.nvim_create_user_command("PeekClose", function()
			if peek.is_open() then
				peek.close()
			end
		end, { desc = "Close markdown live preview" })

		vim.keymap.set("n", "<leader>po", require("peek").open, { desc = "Markdown: open live preview" })
		vim.keymap.set("n", "<leader>pc", require("peek").close, { desc = "Markdown: close live preview" })
	end,
}

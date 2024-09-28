-- Entering explorer under current file,
-- returning to the last explorer location or getting back to file
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pr", vim.cmd.Rexplore)

-- Moving selected text up and down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keeping cursor in place while joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keeping search results in the middle of the screen
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Pasting without breaking the buffer
vim.keymap.set("x", "<leader>p", '"_dP')

-- Pasting from system buffer
-- Remember system-wide <Shift+insert> or <C-V>

-- Yanking to system buffer
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Deleting to system buffer
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- Exiting visual block changes saved
vim.keymap.set("i", "<C-c>", "<Esc>")

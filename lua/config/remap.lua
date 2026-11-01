-- Netrw file explorer navigation
vim.keymap.set("n", "<leader>pe", vim.cmd.Ex, { desc = "Open Netrw explorer" })
vim.keymap.set("n", "<leader>pr", vim.cmd.Rexplore, { desc = "Return to last Netrw location" })

-- Move selected lines up/down in visual mode with auto-indent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Join lines below without moving cursor position
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below and preserve cursor" })

-- Keep search matches centered on screen
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search match (centered)" })

-- Paste over selection without overwriting default register (black hole)
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

-- Yank to system clipboard (+ register)
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("v", "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "Yank line to system clipboard" })

-- Delete to black hole register (preserve clipboard)
vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete without overwriting register" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Delete selection without overwriting register" })

-- Scroll half-page down/up and keep cursor centered
vim.keymap.set("n", "<C-j>", "<C-d>zz", { desc = "Scroll half-page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll half-page up (centered)" })

-- Decrement number alias (since Harpoon remaps <C-x>)
vim.keymap.set("n", "<C-z>", "<C-x>", { desc = "Decrement number under cursor" })

-- Exit terminal mode quickly
vim.keymap.set("t", "<C-[><C-[>", "<c-\\><c-n>", { desc = "Exit terminal mode to normal mode" })

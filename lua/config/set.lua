vim.opt.guicursor = ""
--vim.opt.cursorline = true

-- Set the default file format to Unix
-- It fixes the messing up files in Windows, yeah I know, it is annoying
-- vim.opt.fileformat = "unix"
-- vim.opt.encoding = "utf-8"
-- vim.opt.fileencoding = "utf-8"

vim.opt.title = true

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "81"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 4
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 34

vim.o.keywordprg = ":help"

vim.o.shell = "zsh"
-- Powershell policies
-- vim.o.shellcmdflag = "-nologo -noprofile -ExecutionPolicy RemoteSigned -command"
-- vim.o.shellxquote = ""

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom_term_open", { clear = true }),
	callback = function()
		vim.opt.nu = false
		vim.opt.relativenumber = false
		vim.opt.signcolumn = "no"
		vim.opt.winhighlight = "Normal:normal"
	end,
})

vim.opt.list = true
vim.opt.listchars:append({
	multispace = ". ",
	tab = "┊ ",
	lead = "·",
	leadmultispace = "· ",
	trail = "~",
	extends = ">",
	precedes = "<",
	nbsp = "+",
})

vim.filetype.add({ extension = { templ = "templ" } })

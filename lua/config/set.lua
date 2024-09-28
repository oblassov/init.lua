vim.opt.guicursor = ""
--vim.opt.cursorline = true

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
vim.opt.undodir = os.getenv("HOMEPATH") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 9
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "82"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

vim.o.keywordprg = ":help"

vim.o.shell = "pwsh"
vim.o.shellcmdflag = "-nologo -noprofile -ExecutionPolicy RemoteSigned -command"
vim.o.shellxquote = ""

vim.opt.list = true
vim.opt.listchars:append({
	multispace = " . .",
	tab = "· ",
	lead = ".",
	leadmultispace = ". . ",
	trail = "~",
	extends = ">",
	precedes = "<",
	nbsp = "+",
})

vim.filetype.add({ extension = { templ = "templ" } })

-- Disable unused remote providers for faster startup and cleaner healthcheck
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Disables GUI-style cursor (useful in terminal Vim to use the terminal's cursor)
vim.opt.guicursor = ""

-- Highlights the current line with a different background color
-- vim.opt.cursorline = true

-- Sets the default file format to Unix (LF line endings)
-- Prevents issues with line endings when working across different operating systems
-- vim.opt.fileformat = "unix"
-- vim.opt.encoding = "utf-8"        -- Sets the internal character encoding
-- vim.opt.fileencoding = "utf-8"    -- Sets the encoding for files when written

-- Updates the terminal title to show the current file being edited
vim.opt.title = true

-- Always shows the sign column (where git signs, LSP diagnostics appear)
vim.opt.signcolumn = "yes"

-- Highlights column 81 to indicate where lines should wrap (80 chars + 1)
vim.opt.colorcolumn = "81"

-- Shows line numbers
vim.opt.nu = true
-- Shows relative line numbers (distance from current line)
vim.opt.relativenumber = true

-- Tab settings for indentation:
vim.opt.tabstop = 4 -- Number of spaces a TAB character displays as
vim.opt.softtabstop = 4 -- Number of spaces inserted when pressing TAB in insert mode
vim.opt.shiftwidth = 4 -- Number of spaces for auto-indentation
vim.opt.expandtab = false -- Uses actual TAB characters instead of spaces

-- Indentation settings:
vim.opt.autoindent = true -- Copy indent from current line when starting new line
vim.opt.smartindent = true -- Smart auto-indenting for C-like languages
vim.opt.breakindent = true -- Wrapped lines continue visually indented

-- Disables line wrapping
vim.opt.wrap = false

-- File management settings:
vim.opt.swapfile = false -- Disables swap file creation
vim.opt.backup = false -- Disables backup file creation
-- Sets directory for undo file persistence (allows undo after restart)
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.opt.undofile = true -- Enables persistent undo

-- Search settings:
vim.opt.hlsearch = false -- Disables highlighting of all search matches
vim.opt.incsearch = true -- Enables incremental search (show matches as you type)

-- Enables 24-bit RGB color in the terminal (requires terminal support)
vim.opt.termguicolors = true

-- Screen scrolling margins:
vim.opt.scrolloff = 8 -- Minimum lines to keep above/below cursor
vim.opt.sidescrolloff = 4 -- Minimum columns to keep left/right of cursor
-- Adds special characters to be considered as part of filenames
vim.opt.isfname:append("@-@")

-- Timing settings:
vim.opt.updatetime = 50 -- Milliseconds before swap file is written (also affects CursorHold events)
vim.opt.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete

-- Leader key configuration (used for custom key mappings):
vim.g.mapleader = " " -- Global leader key (spacebar)
vim.g.maplocalleader = " " -- Local buffer leader key
vim.g.have_nerd_font = true -- Indicates Nerd Font is installed (used by some plugins)

-- Netrw (built-in file explorer) settings:
vim.g.netrw_browse_split = 0 -- Opens files in the same window
vim.g.netrw_winsize = 34 -- Sets initial width of Netrw window to 34 columns

-- Sets the command to run when using K in normal mode (help lookup)
vim.o.keywordprg = ":help"

-- PowerShell configuration
-- vim.o.shellcmdflag = "-nologo -noprofile -ExecutionPolicy RemoteSigned -command"
-- vim.o.shellxquote = ""

-- Autocommand group for terminal behavior:
-- When a terminal buffer opens, this disables line numbers and sign column
-- for a cleaner terminal appearance
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("custom_term_open", { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.winhighlight = "Normal:normal" -- Resets highlighting for terminal window
	end,
})

-- Shows invisible characters:
vim.opt.list = true
-- Custom characters to represent invisible characters:
vim.opt.listchars:append({
	multispace = ". ", -- Multiple spaces
	tab = "┊ ", -- Tab character
	lead = "·", -- Leading spaces
	leadmultispace = "· ", -- Leading multiple spaces
	trail = "~", -- Trailing spaces
	extends = ">", -- Last column when line continues right
	precedes = "<", -- First column when line continues left
	nbsp = "+", -- Non-breaking spaces
})

-- Adds filetype detection for .templ files (likely HTML templating)
vim.filetype.add({ extension = { templ = "templ", tmpl = "gotmpl", gotmpl = "gotmpl" } })

require("config.set")
require("config.remap")
require("config.lazy_init")

vim.filetype.add({ extension = { templ = "templ" } })

vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

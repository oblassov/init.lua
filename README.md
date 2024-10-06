# init.lua

Personal setup that works on any system (Unix users need to comment out a line in undotree.lua that changes DIFF to FC)
- [ripgrep](https://github.com/BurntSushi/ripgrep) is a prerequisite
- Plugins are installed with Lazy.nvim and kept in a [lua/config](/lua/config/) directory
- Beware of the light mode (default colorscheme is [tokyonight-day](https://github.com/folke/tokyonight.nvim), configurable in [colors.lua](lua/config/lazy/colors.lua))
- [Telescope](https://github.com/nvim-telescope/telescope.nvim), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter), [treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context), [Fugitive](https://github.com/tpope/fugitive), [harpoon](https://github.com/ThePrimeagen/harpoon), [undotree](https://github.com/mbbill/undotree)
- Simple LSP (documentation, autocomplete, autoformat) set up for Go (gopls and gofmt), Java (jdtls), Lua (luals and stylua) and Markdown (markdown-oxide)
- [Vimbegood](https://github.com/theprimeagen/vim-be-good) for some vim motions practice
- Remaps are kept simple and as close to defaults as possible. [remaps.lua](lua/config/remaps.lua) is for general remaps and plugin specific remaps are kept within plugin setup files
- Heavily inspired by [theprimeagen](https://github.com/nvim-lua/init.lua) and [kickstart](https://github.com/nvim-lua/kickstart.nvim/) setups

# init.lua

Personal setup that works on any system (for Unix users need to comment out a line in undotree.lua that changes DIFF to FC)
- [ripgrep](https://github.com/BurntSushi/ripgrep) is a prerequisite
- Plugins are installed with Lazy.nvim and kept in a config folder
- [Telescope](https://gihub.com/nvim-telescope/telescope.nvim), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter), [harpoon](https://github.com/ThePrimeagen/harpoon), [undotree](https://github.com/mbbill/undotree)
- Simple LSP (documentation, autocomplete, autoformat) setup for Go (gopls and gofmt), Java (jdtls), Lua (luals and stylua) and Markdown (markdown-oxide)
- Has [Peek](https://github.com/toppair/peek.nvim/) for markdown preview. (might change in future, planning to make a simple notetaking setup)
- [Vimbegood](https://github.com/theprimeagen/vim-be-good) for some vim motions practice
- ColorScheme is TokioNight Day (can be changed in the [colors.lua](lua/config/lazy/colors.lua))
- Remaps are kept simple, though will be changed once in a while
- Heavily inspired by [theprimeagen](https://github.com/nvim-lua/init.lua) and [kickstart](https://github.com/nvim-lua/kickstart.nvim/) setups

# init.lua

Personal setup that works on any system (Unix users need to comment out a line in undotree.lua that changes DIFF to FC)
- Beware of the light mode (you can switch to dark mode, as well as configuring and adding more colorschemes(default is TokioNight Day) and other looks in [colors.lua](lua/config/lazy/colors.lua))
- [ripgrep](https://github.com/BurntSushi/ripgrep) is a prerequisite
- Plugins are installed with Lazy.nvim and kept in a lua/config directory
- [Telescope](https://gihub.com/nvim-telescope/telescope.nvim), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter), [harpoon](https://github.com/ThePrimeagen/harpoon), [undotree](https://github.com/mbbill/undotree)
- Simple LSP (documentation, autocomplete, autoformat) setup for Go (gopls and gofmt), Java (jdtls), Lua (luals and stylua) and Markdown (markdown-oxide)
- [Peek](https://github.com/toppair/peek.nvim/) for markdown preview. (might change in future, planning to make a simple note-taking setup)
- [Vimbegood](https://github.com/theprimeagen/vim-be-good) for some vim motions practice
- Remaps are kept simple and as close to defaults as possible. [remaps.lua](lua/config/remaps.lua) is for general remaps and plugin specific remaps are kept within plugin setup files
- Heavily inspired by [theprimeagen](https://github.com/nvim-lua/init.lua) and [kickstart](https://github.com/nvim-lua/kickstart.nvim/) setups

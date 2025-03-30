# init.lua

Very simple personal setup that works on any system (Windows users need to comment out a line in undotree.lua that changes DIFF to FC)
- Neovim 0.11+ and [ripgrep](https://github.com/BurntSushi/ripgrep) are prerequisites
- Plugins are installed with Lazy.nvim and kept in a [lua/config](/lua/config/) directory
- Beware of the light mode (default colorscheme is [tokyonight-day](https://github.com/folke/tokyonight.nvim), configurable in [colors.lua](lua/config/lazy/colors.lua)), ColorMyPencil <theme-name> command hotswaps the theme
- [Telescope](https://github.com/nvim-telescope/telescope.nvim), [treesitter](https://github.com/nvim-treesitter/nvim-treesitter), [treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context), [Fugitive](https://github.com/tpope/fugitive), [harpoon](https://github.com/ThePrimeagen/harpoon), [undotree](https://github.com/mbbill/undotree), [trouble](https://github.com/folke/trouble.nvim)
- [peek](https://github.com/toppair/peek.nvim) for markdown files preview ([deno](https://deno.com/) is a prerequisite)
- Simple LSP (documentation, autocomplete, autoformat) set up for Go (gopls and gofmt), Lua (luals and stylua) and Markdown (markdown-oxide)
- Golangci-lint tool is setup to check for project config files and fallback to global config in the configured directory (~/.config/golangci-lint as the default path)
- Remaps are kept simple and as close to defaults as possible. [remaps.lua](lua/config/remaps.lua) is for general remaps and plugin specific remaps are kept within plugin setup files
- Heavily inspired by [theprimeagen](https://github.com/nvim-lua/init.lua) and [kickstart](https://github.com/nvim-lua/kickstart.nvim/) setups
- Contains a WIP version of termit plugin for split terminal window that keeps state

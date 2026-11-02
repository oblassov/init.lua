# init.lua

A simple, fast, and modern personal Neovim configuration built with native Lua and designed to be portable across Linux, macOS, and Windows.

- **Target**: Neovim 0.12+ (required by nvim-treesitter's `main` branch; leverages native `vim.iter`, `vim.lsp`, `vim.treesitter`, and `stdpath`).
- **Inspirations**: Heavily inspired by [ThePrimeagen](https://github.com/ThePrimeagen/init.lua) and [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/).
- **Philosophy**: Pure Lua, zero legacy remote provider overhead (Python, Ruby, Perl, Node providers disabled), fast startup, and sensible defaults close to standard Vim behavior.

---

## Prerequisites & Dependencies

### Core Requirements (All Systems)
- **Neovim** >= 0.12
- **[Git](https://git-scm.com/)**: Required by [lazy.nvim](https://github.com/folke/lazy.nvim) for cloning and updating plugins.
- **C Compiler (`gcc` or `clang`)** & **`make`**: Required to compile native extensions ([`telescope-fzf-native.nvim`](https://github.com/nvim-telescope/telescope-fzf-native.nvim) and tree-sitter parsers).
- **[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md)** >= 0.26.1: Required by nvim-treesitter to build parsers. Install it from your system package manager (e.g. `pacman -S tree-sitter-cli`, `brew install tree-sitter-cli`), **not npm**.
- **[ripgrep](https://github.com/BurntSushi/ripgrep)**: Required for live multigrep, project-wide search, and Telescope.

### Optional Tooling
- **[Deno](https://deno.com/)**: Required only for [peek.nvim](https://github.com/toppair/peek.nvim) (live browser markdown preview).
- **[lazygit](https://github.com/jesseduffield/lazygit)**: Required for the floating Git terminal window (`<leader>lg`).
- **Nerd Font**: Optional, but recommended for clean diagnostic signs, status badges, and Lazy UI icons (`vim.g.have_nerd_font = true` in [`set.lua`](lua/config/set.lua)).
- **Clipboard Tool**:
  - Linux Wayland: `wl-clipboard` (`wl-copy` / `wl-paste`)
  - Linux X11: `xclip` or `xsel`
  - macOS & Windows: Supported natively out of the box (`pbcopy` / win32 clipboard).

---

## Installed Plugins

All plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and modularized inside the [`lua/config/lazy/`](lua/config/lazy/) directory.

Plugins marked † track their latest stable SemVer release (`version = "*"`); the rest follow their default branch, because their tags are missing or years out of date. Updates only happen on demand via `:Lazy update`.

| Category | Plugins | Purpose |
| :--- | :--- | :--- |
| **Theme & UI** | [`folke/tokyonight.nvim`](https://github.com/folke/tokyonight.nvim) † | Main theme (defaults to `tokyonight-day`). Hotswap themes with `:ColorMyPencils <theme>`. |
| | [`j-hui/fidget.nvim`](https://github.com/j-hui/fidget.nvim) † | Lightweight status & progress notifications for LSP. |
| | [`lukas-reineke/indent-blankline.nvim`](https://github.com/lukas-reineke/indent-blankline.nvim) † | Visual indentation guides and active scope indicators. |
| **Navigation & Search** | [`nvim-telescope/telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim) † | Modular fuzzy finder (Ivy theme layout). |
| | [`nvim-telescope/telescope-fzf-native.nvim`](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | High-performance C-based fzf sorter for Telescope. |
| | [`ThePrimeagen/harpoon`](https://github.com/ThePrimeagen/harpoon) | Harpoon 2 for fast home-row buffer pinning and switching. |
| | [`local/telescope/multigrep`](lua/config/local/telescope/multigrep.lua) | Custom async two-query picker (pattern + file filter via `  `). |
| **Syntax & Treesitter** | [`nvim-treesitter/nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter) | Parser manager on the `main` branch: installs parsers to `stdpath("data")/site` and enables Neovim's built-in treesitter highlighting and indentation via a `FileType` autocmd. Missing parsers auto-install on first use. |
| | [`nvim-treesitter/nvim-treesitter-context`](https://github.com/nvim-treesitter/nvim-treesitter-context) † | Sticky context header showing the enclosing function/class. |
| **LSP & Tool Management** | [`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) † | Quickstart configs for Neovim's built-in LSP client. |
| | [`mason-org/mason.nvim`](https://github.com/mason-org/mason.nvim) † | Portable package manager for LSP servers, linters, and formatters. |
| | [`mason-org/mason-lspconfig.nvim`](https://github.com/mason-org/mason-lspconfig.nvim) † | Seamless bridge between Mason and `lspconfig`. |
| | [`WhoIsSethDaniel/mason-tool-installer.nvim`](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) | Automatically installs missing Mason packages on startup. |
| | [`folke/lazydev.nvim`](https://github.com/folke/lazydev.nvim) † & [`Bilal2453/luvit-meta`](https://github.com/Bilal2453/luvit-meta) | Lua LSP configuration for Neovim API, runtime, and plugins. |
| **Completion & Snippets** | [`hrsh7th/nvim-cmp`](https://github.com/hrsh7th/nvim-cmp) | Extensible completion engine with border styling and custom source icons. |
| | [`L3MON4D3/LuaSnip`](https://github.com/L3MON4D3/LuaSnip) † | Powerful snippet engine with expandable jump keymaps. |
| | [`rafamadriz/friendly-snippets`](https://github.com/rafamadriz/friendly-snippets) | Comprehensive collection of pre-made language snippets. |
| | `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip` | Specialized completion sources. |
| **Formatting** | [`stevearc/conform.nvim`](https://github.com/stevearc/conform.nvim) † | Format-on-save and on-demand formatting (`<leader>f`). |
| **Git & Terminal** | [`tpope/vim-fugitive`](https://github.com/tpope/vim-fugitive) | Comprehensive Git client with 3-way merge conflict helpers. |
| | [`local/termit`](lua/config/local/termit.lua) | Custom terminal manager: floating LazyGit (`<leader>lg`) and stateful split terminal (`<C-\>`). |
| **Diagnostics & Tools** | [`folke/trouble.nvim`](https://github.com/folke/trouble.nvim) † | Pretty diagnostics, references, quickfix, and symbols list. |
| | [`mbbill/undotree`](https://github.com/mbbill/undotree) | Visualizes persistent undo history tree (`<leader>u`). |
| | [`toppair/peek.nvim`](https://github.com/toppair/peek.nvim) | Live markdown preview in browser (`<leader>po` / `<leader>pc`). |
| **Libraries** | [`nvim-lua/plenary.nvim`](https://github.com/nvim-lua/plenary.nvim) | Common Lua utilities required by Telescope, Harpoon, and others. |

---

## Language Tooling

Language-specific servers and formatters are configured in [`lua/config/lazy/lsp.lua`](lua/config/lazy/lsp.lua) and [`lua/config/lazy/autoformat.lua`](lua/config/lazy/autoformat.lua):

- **Go**: `gopls` (LSP with semantic tokens & codelenses), `golangci-lint-langserver` (detects local `.golangci.yml` or global `~/.config/golangci-lint/.golangci.yml`), and `gofmt` (via Conform).
- **Lua**: `lua-language-server` (`lua_ls` with Neovim API globals and `lazydev`), and `stylua` (via Conform).
- **Markdown**: `markdown-oxide` (PKM & link completions) and `peek.nvim` for rendering.
- **HTML & Templ**: `vscode-html-language-server` and `templ`.

---

## Key Mapping Highlights

General mappings are defined in [`lua/config/remap.lua`](lua/config/remap.lua), while plugin-specific mappings live in their respective plugin files:

### General ([`remap.lua`](lua/config/remap.lua))
- `<leader>pe` / `<leader>pr`: Open Netrw file explorer / return to previous location.
- Visual `J` / `K`: Move selected block down / up while maintaining indentation.
- Normal `J`: Join line below while keeping cursor position fixed.
- `n` / `N`: Next / previous search result (automatically centered on screen).
- Visual `<leader>p`: Paste over selection without losing current register contents (black-hole delete).
- `<leader>y` / `<leader>Y`: Yank to system clipboard.
- `<leader>d`: Delete into black-hole register (preserves clipboard).
- `<C-j>` / `<C-u>`: Scroll half-page down / up with cursor centered.
- `<C-z>`: Decrement number under cursor (alias for `<C-x>`).
- Terminal `<C-[><C-[>`: Quick escape from terminal to normal mode.

### Harpoon 2 ([`harpoon.lua`](lua/config/lazy/harpoon.lua))
- `<leader>h` / `<leader>H`: Append / prepend file to Harpoon list.
- `<C-h>`: Toggle Harpoon quick menu.
- `<C-f>`, `<C-d>`, `<C-s>`, `<C-v>`, `<C-c>`, `<C-x>`: Jump directly to pinned slots 1 through 6.
- `<leader><C-f>` ...: Replace file at slots 1 through 6 with active buffer.

### Telescope ([`telescope.lua`](lua/config/lazy/telescope.lua))
- `<leader>pf`: Find files in project.
- `<C-p>`: Find git tracked files (falls back to `find_files` if outside a repo).
- `<leader>ps`: Live MultiGrep (`pattern  *.ext` search).
- `<leader>pws` / `<leader>pWs`: Search word / WORD under cursor.
- `<leader>fh`: Browse help documentation tags.
- `<leader>ph`: Browse Harpoon items in Telescope.
- `<leader>cn`: Search Neovim configuration files.
- `<leader>fn`: Search installed Lazy plugins.

### Termit & Git ([`termit.lua`](lua/config/lazy/termit.lua), [`fugitive.lua`](lua/config/lazy/fugitive.lua))
- `<leader>lg`: Toggle floating LazyGit window (press `q` to exit, `<C-]>` to hide).
- `<C-\>`: Toggle persistent side terminal split.
- `<leader>gt`: Open Fugitive Git status window.
- Normal `gu` / `gh`: Merge conflict resolution — take LOCAL (`//2`) or REMOTE (`//3`) change.

### Formatting & Tools
- `<leader>f`: Format current buffer (Conform / LSP fallback).
- `<leader>u`: Toggle Undotree visual history.
- `<leader>th`: Toggle LSP inlay hints (buffer-local).
- `<leader>xx` / `<leader>xX`: Toggle Trouble diagnostics (workspace / buffer).
- `<leader>po` / `<leader>pc`: Open / close live Markdown preview in browser.

---

## Cross-Platform & Windows Notes

This configuration is designed to be cross-platform out of the box:
- **Persistent Undo**: Uses standard `vim.fn.stdpath("state") .. "/undo"`, which resolves correctly on Linux (`~/.local/state/nvim/undo`), macOS (`~/.local/state/nvim/undo`), and Windows (`%LOCALAPPDATA%\nvim-data\undo`). No manual `$HOME` environment variable configuration is required.
- **Shell**: Automatically detects if `zsh` is installed before setting it, cleanly falling back to PowerShell / `cmd.exe` on Windows or `bash`/`sh` on Linux.

### Windows Considerations:
1. **Compilers**: Ensure you have a working C compiler (`gcc` via MinGW-w64, MSYS2, or `clang`), `make`, and the `tree-sitter` CLI on your `%PATH%` to allow building `telescope-fzf-native` and tree-sitter parsers. See the [nvim-treesitter requirements](https://github.com/nvim-treesitter/nvim-treesitter#requirements).
2. **Undotree**: On Windows without `diff.exe` installed, uncomment `vim.g.undotree_DiffCommand = "FC"` inside [`lua/config/lazy/undotree.lua`](lua/config/lazy/undotree.lua) to use the built-in Windows file compare utility.
3. **Execution Policy**: If using PowerShell in Neovim terminal or mason scripts, ensure your execution policy permits script execution:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

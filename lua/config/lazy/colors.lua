-- =============================================================================
-- TokyoNight Day Crisp (Light) + stock TokyoNight Night (Dark) for Neovim
-- Target Light Canvas: #fafafb (Ghostty `background`, shown through `transparent = true`)
-- All contrast ratios below are WCAG 2.x, measured against `#fafafb` unless noted
-- =============================================================================

-- Resolve the absolute path of this file so `:ColorMyPencils` can hot-reload edits
local config_path = debug.getinfo(1, "S").source:sub(2)

-- Global helper to apply a colorscheme by name (defaults to `tokyonight`)
function _G.ColorMyPencils(color)
	vim.cmd.colorscheme((color and color ~= "") and color or "tokyonight")
end

-- User command to hot-reload saved edits from this file without restarting Neovim
vim.api.nvim_create_user_command("ColorMyPencils", function(cmd_opts)
	if config_path ~= "" and vim.uv.fs_stat(config_path) then
		-- Re-execute this spec file to read updated `opts` and re-run `setup()`
		local ok_spec, spec = pcall(dofile, config_path)
		if ok_spec and type(spec) == "table" and spec.opts then
			require("tokyonight").setup(spec.opts)
		end
	end
	ColorMyPencils(cmd_opts.args)
end, { nargs = "?", desc = "Reload and apply colorscheme" })

return {
	"folke/tokyonight.nvim",
	lazy = false, -- Load immediately on startup
	priority = 1000, -- Load before all other UI/syntax plugins
	opts = {
		style = "night", -- Default dark variant ("storm", "moon", "night", or "day")
		light_style = "day", -- Automatically selected when `vim.o.background == "light"`
		transparent = true, -- Keep main editor canvas transparent so Ghostty renders `#fafafb`
		terminal_colors = true, -- Sync ANSI 0-15 palette to Neovim `:terminal` buffers
		day_brightness = 0.25, -- Default 0.30; darker inks add ~10-14% contrast on `#fafafb`
		-- without crushing HSLuv chroma/saturation (which happens at 0.15)
		dim_inactive = true, -- Dim unfocused splits for clear active-window focus
		lualine_bold = true, -- Bold section headers in lualine
		cache = false, -- Always rebuild so `on_colors` / `on_highlights` edits apply immediately

		styles = {
			comments = { italic = true },
			keywords = { italic = true },
			functions = {},
			variables = {},
			sidebars = "transparent", -- Keep file trees / sidebars transparent
			floats = "normal", -- Solid subtle tint in light mode prevents buffer text bleed-through
		},

		-- =====================================================================
		-- Palette Mutations (run after tokyonight derives its own colors such as
		-- `error`, `warning`, `diff` and `terminal`, but BEFORE highlight groups
		-- are generated, so only keys read by the groups themselves take effect)
		-- =====================================================================
		on_colors = function(c)
			if vim.o.background ~= "light" then
				return
			end

			-- Base surfaces
			c.bg = "#fafafb" -- Match Ghostty light bg (stock day bg is `#e1e2e7`)
			c.bg_float = "#f2f3f7" -- Cool off-white surface for floating windows (1.06:1)

			-- Re-base tokyonight's group-time blends (diagnostic virtual text pills,
			-- signature help, markdown heading pills) onto the real `#fafafb` canvas
			-- instead of stock `#e1e2e7`. `Util.bg`/`Util.fg` are tokyonight internals.
			local util = require("tokyonight.util")
			util.bg = c.bg
			util.fg = "#2c3659"

			-- Core syntax inks
			c.fg = "#2c3659" -- 11.32:1 (AAA) | Deep slate-navy for plain text and variables;
			-- decouples variables from `#2a75da` blue function calls (stock `#3760bf` 5.61:1)
			c.fg_float = c.fg -- Float text follows the new ink (tokyonight copies `fg` before this hook)
			c.green = "#48682c" -- 6.12:1 (AA) | Rich forest green for strings (stock `#587539` 5.01:1)
			c.red = "#c64343" -- 4.70:1 (AA) | Terracotta red for builtins & HTML tags
			-- (replaces neon `#f52a65` at 3.73:1; diagnostics already use `red1` = `#c64343`)
			c.yellow = "#937a00" -- 4.01:1 | Gold for parameters, flags, warnings and search;
			-- max sRGB chroma at OKLCH hue 95°, so darkening keeps it gold rather than
			-- the stock brown `#8c6c3e` (hue 75°, half the chroma)
			c.warning = c.yellow -- Warnings use the same gold (tokyonight copies `yellow` before this hook)
			c.orange = "#b85600" -- 4.61:1 (AA) | Burnt tangerine for numbers & constants

			-- UI neutrals
			c.comment = "#636b94" -- 4.96:1 (AA) | Up from stock `#848cb5` (3.15:1), +57%,
			-- while staying visually subordinate to active code

			-- Full 16-color ANSI `:terminal` palette on `#fafafb`
			-- Normal (0-7) uses deeper inks; Bright (8-15) steps up chroma & vibrancy
			-- while keeping every text color above WCAG AA (except intentionally bright yellow 11)
			c.terminal = {
				black = "#e4e6ee", -- 1.19:1 | Surface badge fill (light theme: ANSI 0 is a background tone)
				black_bright = "#5c638a", -- 5.58:1 (AA) | Fixes faint shell ghost text
				-- (`zsh-autosuggestions` / Fish completions) in `:terminal`
				red = "#b83232", -- 5.69:1 | Deep crimson (normal ANSI 1)
				red_bright = "#dc2638", -- 4.60:1 | Vivid scarlet (bright ANSI 9)
				green = "#3d6324", -- 6.69:1 | Deep forest (normal ANSI 2)
				green_bright = "#2d7a36", -- 5.10:1 | Punchy emerald (bright ANSI 10)
				yellow = "#937a00", -- 4.01:1 | Gold, same as `c.yellow` (normal ANSI 3)
				yellow_bright = "#b89c00", -- 2.58:1 | Canary gold (bright ANSI 11; avoids brown shift)
				blue = "#2459b8", -- 6.30:1 | Deep cobalt (normal ANSI 4)
				blue_bright = "#226ae6", -- 4.71:1 | Electric azure (bright ANSI 12)
				magenta = "#6b3fa8", -- 6.94:1 | Royal violet (normal ANSI 5)
				magenta_bright = "#9838d9", -- 5.16:1 | Vivid orchid (bright ANSI 13)
				cyan = "#006485", -- 6.37:1 | Deep ocean teal (normal ANSI 6)
				cyan_bright = "#007ca3", -- 4.56:1 | Bright cerulean (bright ANSI 14)
				white = "#4b5680", -- 6.84:1 | Muted indigo (normal ANSI 7)
				white_bright = "#2c3659", -- 11.32:1 | Deep slate-navy (bright ANSI 15)
			}
		end,

		-- =====================================================================
		-- Highlight Overrides (executed AFTER highlight groups are generated)
		-- Dark mode uses stock TokyoNight Night untouched
		-- =====================================================================
		on_highlights = function(hl, c)
			if vim.o.background ~= "light" then
				return
			end

			-- -------------------------------------------------------------
			-- 1. Core Editor Surfaces, Floats & Sticky Context
			-- -------------------------------------------------------------
			-- `Normal`, `NormalNC` and `NormalFloat` come from `transparent`, `c.fg` and
			-- `c.bg_float`; overriding them here would also wipe their foreground
			hl.FloatBorder = { fg = "#6f79a3", bg = c.bg_float } -- 3.83:1 on `#f2f3f7` (UI 3:1)

			-- Line numbers only: darkening `c.fg_gutter` instead would also darken
			-- fold backgrounds, indent guides, `listchars` and scrollbars
			hl.LineNr = { fg = "#767ea6" } -- 3.79:1 (UI 3:1), up from stock `#a8aecb` (2.10:1)
			hl.LineNrAbove = { fg = "#767ea6" }
			hl.LineNrBelow = { fg = "#767ea6" }

			-- Closed folds: stock paints blue on the gutter grey (1.83:1)
			hl.Folded = { fg = c.blue, bg = "#e6eaf5" } -- 3.75:1, soft band (1.15:1 vs canvas)

			-- `colorcolumn = "81"`: stock `#b4b5b9` bar is heavy on `#fafafb` (1.96:1)
			hl.ColorColumn = { bg = "#ebedf5" } -- 1.12:1, visible but quiet

			hl.Pmenu = { bg = "#f1f2f7" } -- Completion popup menu background
			hl.PmenuSel = { bg = "#c6cfe3", bold = true } -- Active item (`#2c3659` text = 7.55:1)

			hl.Visual = { bg = "#c4d6ed" } -- Soft slate-blue selection (1.42:1;
			-- `#2c3659` text on `#c4d6ed` = 7.98:1 WCAG AAA)
			hl.VisualNC = { bg = "#c4d6ed" }
			hl.VisualNOS = { bg = "#c4d6ed" }

			-- Sticky Treesitter context header (all 4 groups required so gutter isn't dark)
			hl.TreesitterContext = { bg = "#ebedf5" }
			hl.TreesitterContextLineNumber = { fg = "#767ea6", bg = "#ebedf5" } -- 3.39:1 on `#ebedf5`
			hl.TreesitterContextBottom = { sp = "#c6cfe3", underline = true }
			hl.TreesitterContextLineNumberBottom = { sp = "#c6cfe3", underline = true }

			-- LSP document highlight (symbol under cursor) & references
			-- Overrides tokyonight's default `bg = c.fg_gutter`, a mid-grey band on this canvas
			hl.LspReferenceText = { bg = "#dfe4f2" } -- `#2c3659` text on `#dfe4f2` = 9.28:1
			hl.LspReferenceRead = { bg = "#dfe4f2" }
			hl.LspReferenceWrite = { bg = "#d3dcf0", sp = c.blue, underline = true } -- `#2c3659` text = 8.58:1
			hl.LspReferenceTarget = { bg = "#d3dcf0", sp = c.blue, underline = true }
			hl.IlluminatedWordText = { bg = "#dfe4f2" }
			hl.IlluminatedWordRead = { bg = "#dfe4f2" }
			hl.IlluminatedWordWrite = { bg = "#d3dcf0", sp = c.blue, underline = true }
			hl.MiniCursorword = { bg = "#dfe4f2" }
			hl.MiniCursorwordCurrent = { bg = "#d3dcf0" }

			-- Search pills: pale gold for all matches, solid gold for the current one
			hl.Search = { fg = "#5c4300", bg = "#f9eab0" } -- 7.72:1 (AAA)
			hl.IncSearch = { fg = "#fafafb", bg = c.yellow } -- 4.01:1 (white-on-gold)
			hl.CurSearch = { fg = "#fafafb", bg = c.yellow }

			-- Inline completion ghost text and LSP inlay hints
			hl.ComplHint = { fg = "#636b94" } -- 4.96:1 (AA)
			hl.LspInlayHint = { fg = "#636b94", bg = "#f1f2f7" } -- 4.63:1 on `#f1f2f7`

			-- -------------------------------------------------------------
			-- 2. Shared Cross-Language Token Hierarchy (Treesitter + LSP)
			-- -------------------------------------------------------------
			hl["@variable"] = { fg = c.fg } -- Slate-navy `#2c3659` (11.32:1) anchors base identifiers
			hl["@variable.parameter"] = { fg = c.yellow } -- Gold `#937a00` (4.01:1)
			hl["@variable.member"] = { fg = c.green1 } -- Deep teal (`#32665e`, 6.30:1) for fields & keys
			hl["@property"] = { fg = c.green1 }

			hl["@function"] = { fg = c.blue, bold = true } -- Cobalt blue (`#2a75da`, 4.32:1), bold on definitions
			hl["@function.method"] = { fg = c.blue, bold = true }
			hl["@function.call"] = { fg = c.blue }
			hl["@function.method.call"] = { fg = c.blue }
			hl["@function.builtin"] = { fg = c.blue1 }

			hl["@type"] = { fg = c.blue1 } -- Deep cyan (`#157687`, 5.07:1) separates types from functions
			hl["@type.builtin"] = { fg = c.blue1, italic = true }
			hl["@module"] = { fg = "#5a4a9c" } -- Indigo (`#5a4a9c`, 6.96:1) for package/module qualifiers
			hl["@constant"] = { fg = c.orange } -- Burnt tangerine `#b85600` (4.61:1)
			hl["@constant.builtin"] = { fg = c.orange, bold = true } -- `nil`, `true`, `false`, `iota`

			-- Mirror hierarchy into LSP semantic tokens (priority 125 > Treesitter 100)
			hl["@lsp.type.variable"] = { fg = c.fg }
			hl["@lsp.type.parameter"] = { fg = c.yellow }
			hl["@lsp.type.property"] = { fg = c.green1 }
			hl["@lsp.type.namespace"] = { fg = "#5a4a9c" }
			hl["@lsp.type.type"] = { fg = c.blue1 }
			hl["@lsp.type.interface"] = { fg = c.blue1, italic = true }

			-- -------------------------------------------------------------
			-- 3. Main Priority Languages: Go, Shell, JSON, jq, Markdown
			-- -------------------------------------------------------------
			-- Go: distinct package qualifiers and built-in types (`error`, `int`, `string`)
			hl["@type.builtin.go"] = { fg = c.blue1, bold = true }
			hl["@module.go"] = { fg = "#5a4a9c" }
			-- gopls marks `const` as readonly; scoped to Go because TS/JS mark every `const` local
			hl["@lsp.typemod.variable.readonly.go"] = { fg = c.orange }

			-- Shell (`sh` / `bash` / `zsh`): highlight `$VAR` expansions and CLI flags
			hl["@variable.builtin.bash"] = { fg = c.red, bold = true }
			hl["@punctuation.special.bash"] = { fg = c.orange, bold = true } -- `$` and `${}` delimiters
			hl["@variable.parameter.bash"] = { fg = c.yellow } -- Flags (`-f`, `--flag`)

			-- JSON / JSONC: separate quoted keys from quoted string values
			hl["@property.json"] = { fg = c.blue }
			hl["@property.jsonc"] = { fg = c.blue }
			hl["@boolean.json"] = { fg = c.purple, bold = true }
			hl["@constant.builtin.json"] = { fg = c.purple, bold = true } -- `null`

			-- jq: emphasize pipeline operators (`|`) and filter structure
			hl["@operator.jq"] = { fg = c.blue5, bold = true }
			hl["@property.jq"] = { fg = c.green1 }
			hl["@variable.jq"] = { fg = c.orange }

			-- Markdown: stepped bold headings, pill-tinted inline code, clear links
			hl["@markup.heading.1.markdown"] = { fg = c.blue, bold = true }
			hl["@markup.heading.2.markdown"] = { fg = c.purple, bold = true }
			hl["@markup.heading.3.markdown"] = { fg = c.green1, bold = true }
			hl["@markup.heading.4.markdown"] = { fg = c.orange, bold = true }
			hl["@markup.raw.markdown_inline"] = { fg = c.green1, bg = "#eaecf4" }
			hl["@markup.link.label.markdown_inline"] = { fg = c.blue, underline = true }
			hl["@markup.link.url.markdown_inline"] = { fg = "#636b94", underline = true }

			-- -------------------------------------------------------------
			-- 4. Secondary Priority Languages: Python, JS/TS, HTML, CSS
			-- -------------------------------------------------------------
			-- Python: `self`/`cls` and `@decorators`
			hl["@variable.builtin.python"] = { fg = c.red, italic = true }
			hl["@attribute.python"] = { fg = c.orange }

			-- JS / TS / TSX: differentiate JSX components from HTML tags & async flow
			hl["@tag.tsx"] = { fg = c.blue, bold = true }
			hl["@tag.javascript"] = { fg = c.blue, bold = true }
			hl["@keyword.coroutine.typescript"] = { fg = c.purple, italic = true }
			hl["@keyword.coroutine.javascript"] = { fg = c.purple, italic = true }

			-- HTML & CSS: mute tag angle brackets, separate attributes & CSS units
			-- (CSS groups take effect once the `css` treesitter parser is installed)
			hl["@tag"] = { fg = c.red }
			hl["@tag.delimiter"] = { fg = "#636b94" } -- `<`, `>`, `/>`
			hl["@tag.attribute"] = { fg = c.purple }
			hl["@property.css"] = { fg = c.green1 }
			hl["@number.css"] = { fg = c.orange }
			hl["@type.css"] = { fg = c.orange } -- CSS units (`px`, `rem`, `vh`)
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		ColorMyPencils("tokyonight")
	end,
}

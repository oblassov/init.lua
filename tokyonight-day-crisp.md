# TokyoNight Day Crisp

A high-contrast light variant of [tokyonight.nvim](https://github.com/folke/tokyonight.nvim)'s `day` style, tuned
for the `#fafafb` background of the Ghostty terminal. It lives in
[`lua/config/lazy/colors.lua`](lua/config/lazy/colors.lua); a matching Ghostty theme is listed at the end.

Dark mode (`background=dark`) is stock TokyoNight Night with `transparent = true`; nothing below applies to it.

## Method

- **Canvas.** Ghostty draws the background (`#fafafb`) and Neovim stays transparent, so every ratio is measured
  against `#fafafb`, or against the surface a color actually sits on (float, pill, selection) where noted.
- **Contrast.** WCAG 2.x relative-luminance ratio. Targets: **4.5:1** for text (AA), **3:1** for UI marks
  (line numbers, borders, current-search pill). Bold does not count as WCAG "large text" at code font sizes,
  so bold is never used to excuse a low ratio.
- **Hue and saturation.** OKLCH (perceptual lightness, chroma, hue), used to keep a color's identity while
  changing its lightness, which matters most for yellow.
- **"Stock"** below means tokyonight-day at the default `day_brightness = 0.30` on `#fafafb`, which is what this
  config showed before. The previous config also patched `Pmenu` `#f1f2f7`, `PmenuSel` `#d0d5e3`,
  `Visual` `#e1e2e7` (1.24:1 against the canvas, barely visible), `TreesitterContext` `#f1f2f7` and a transparent
  `NormalFloat`. It applied those after the colorscheme loaded, so any reload or `background` change lost them.
- **Measured, not estimated.** Every value in this file was read back from a headless Neovim
  (`nvim_get_hl(0, { link = false })`) after loading the config, then run through the WCAG formula.

## How tokyonight applies the overrides

These facts decide where each change has to go:

1. `colors.setup()` builds the palette, then derives `error = red1`, `warning = yellow`, `diff`, `bg_visual`,
   `border`, `rainbow`, `terminal` and `fg_float`. **Only then** does it call `on_colors`. Changing `c.yellow` in
   `on_colors` therefore does not move warnings; `c.warning` has to be set too. The same applies to `c.fg_float`.
2. Highlight groups are generated **after** `on_colors`, so any group that reads a palette key at that point
   (`c.comment`, `c.bg_float`, `c.green`, …) picks up the new value.
3. Group-time blends (diagnostic virtual-text pills, signature help, markdown heading pills) mix against the
   module field `require("tokyonight.util").bg`, which stays at stock `#e1e2e7` unless reset. `on_colors` sets it
   to `#fafafb`. This is a tokyonight internal: if a release renames it, the pills fall back to stock tints.
4. `on_highlights` replaces a whole group. `hl.Normal = { bg = "none" }` would drop `Normal`'s foreground, so
   `Normal`, `NormalNC` and `NormalFloat` are left to `transparent`, `c.fg` and `c.bg_float`.
5. `c.fg_gutter` is not only the line-number color: tokyonight also uses it for the `Folded` background, indent
   guides, `listchars`, the completion scrollbar and inactive status lines. Line numbers are darkened through
   `LineNr` instead, so none of those change.

## Global settings

| Option | Value | Decision |
|---|---|---|
| `transparent` | `true` | Ghostty draws `#fafafb`; Neovim never paints its own background |
| `day_brightness` | `0.25` (default `0.30`) | Darkens every derived ink ~10-14% (functions 3.85 → 4.32, types 4.43 → 5.07) without the chroma loss seen at `0.15` |
| `styles.floats` | `"normal"` | Floats get a solid `#f2f3f7` tint so buffer text never shows through |
| `styles.comments`, `styles.keywords` | italic | Comments and keywords read as a different voice than identifiers |
| `cache` | `false` | Always rebuild, so `on_colors` / `on_highlights` edits apply on `:ColorMyPencils` |
| `lualine_bold` | `true` | Bold lualine section headers; no effect today because lualine is not installed |

## Palette (`on_colors`)

| Key | Stock | New | Ratio (stock → new) | Decision |
|---|---|---|---|---|
| `bg` | `#e1e2e7` | `#fafafb` | | Matches Ghostty; also the base for group-time blends |
| `bg_float` | `#e1e2e7` | `#f2f3f7` | 1.06 vs canvas | Cool off-white: floats stand apart without a heavy box |
| `fg` | `#3760bf` | `#2c3659` | 5.61 → **11.32** | Deep slate-navy for plain text and variables; also separates variables from blue function calls |
| `fg_float` | `#3760bf` | `= fg` | 10.65 on float | Float text follows the new ink |
| `comment` | `#848cb5` | `#636b94` | 3.15 → **4.96** | +57%, now AA, still clearly quieter than code |
| `green` (strings) | `#587539` | `#48682c` | 5.01 → **6.12** | Deeper forest green |
| `red` | `#f52a65` | `#c64343` | 3.73 → **4.70** | Replaces neon pink-red for builtins and HTML tags; same red diagnostics already used (`red1`) |
| `orange` | `#b15c00` | `#b85600` | 4.58 → 4.61 | Burnt tangerine for numbers and constants, kept distinct from yellow |
| `yellow` | `#8c6c3e` | `#937a00` | 4.65 → **4.01** | Gold, see [Yellow](#yellow) |
| `warning` | `= yellow` (stock) | `= yellow` | 4.65 → 4.01 | Re-linked because tokyonight copies `yellow` before `on_colors` |

Colors left at their `day_brightness = 0.25` value: `blue` `#2a75da` (4.32), `blue1` `#157687` (5.07),
`green1` `#32665e` (6.30), `purple` `#7847bd` (5.86), `magenta` `#9244ef` (4.69), `blue5` `#005f76` (6.95).

## Yellow

Yellow went through three rounds, so the reasoning is recorded in full.

1. **First version:** `#9e8300` (3.53:1), bold on every parameter so it would "read as true yellow rather than
   muddy brown". Bold does not fix a 3.53 ratio, and bold on every parameter use made bold meaningless.
2. **Decision: yellow is treated like every other color.** Every yellow role (parameters, LSP parameter uses,
   shell flags, warnings, `Todo`, `@comment.warning`, docstrings, current-search pill, ANSI 3) uses one value,
   and no bold is tied to the color.
3. **Decision: darker gold at the same hue, `#937a00`.** `#9e8300` already sits at the sRGB maximum chroma for
   its lightness and hue, so the only way to gain contrast is to darken it. Darkening reads as brown when the hue
   moves toward orange and the chroma drops. Stock `#8c6c3e` is hue 75° at chroma 0.075. Holding hue at ~95° and
   taking the maximum chroma at each lightness keeps it gold.

| Candidate | Ratio | In Visual | OKLCH hue / chroma | Verdict |
|---|---|---|---|---|
| `#9e8300` | 3.53 | 2.49 | 94° / 0.127 | Too faint without bold |
| `#987e00` | 3.78 | 2.67 | 94° / 0.123 | Barely different |
| **`#937a00`** | **4.01** | **2.82** | **95° / 0.120** | **Chosen**: +14% contrast, still clearly gold |
| `#897200` | 4.50 | 3.17 | 95° / 0.114 | AA, but starts to read as mustard/olive |
| `#8c6c3e` (stock) | 4.65 | 3.28 | 75° / 0.075 | Brown: wrong hue, half the chroma |

Rejected alternatives: shifting hue to 80-85° (amber, drifts toward brown and toward `orange`); 100-105° (olive);
Ghostty `minimum-contrast` (darkens every faint color with no hue control, pushing yellows to brown).

Accepted trade-off: parameters are the lowest-contrast syntax color (4.01, below AA) and 2.82:1 inside a
selection.

## Emphasis policy

Bold and italic mark **what a token is**, never which color it has.

- **Bold:** function and method definitions (calls are plain), builtin constants (`nil`, `true`, `false`,
  `iota`), Go builtin types, bash `$VAR` and `$`/`${}`, JSON booleans and `null`, jq `|`, markdown headings,
  the selected completion item; stock `CursorLineNr` and `MatchParen`.
- **Italic:** comments, keywords, builtin types, interfaces, Python `self`/`cls`, `async`/`await` keywords.
- **Plain:** parameters, flags and every other yellow token; search pills.

## Syntax hierarchy

Shared by Treesitter captures and LSP semantic tokens (`@lsp.type.*`, priority 125, which beats Treesitter at 100).

| Role | Groups | Color | Ratio (stock → new) |
|---|---|---|---|
| Variables | `@variable`, `@lsp.type.variable` | `fg` `#2c3659` | 5.61 → 11.32 |
| Parameters | `@variable.parameter`, `@lsp.type.parameter` | `yellow` `#937a00` | 4.65 → 4.01 |
| Fields, properties | `@variable.member`, `@property`, `@lsp.type.property` | `green1` `#32665e` | 5.46 → 6.30 |
| Functions | `@function` (bold), `@function.call`, methods | `blue` `#2a75da` | 3.85 → 4.32 |
| Builtin functions | `@function.builtin` | `blue1` `#157687` | 4.43 → 5.07 |
| Types | `@type`, `@type.builtin` (italic), `@lsp.type.type`, `@lsp.type.interface` (italic) | `blue1` `#157687` | 4.43 / 3.36 → 5.07 |
| Modules, packages | `@module`, `@lsp.type.namespace` | `#5a4a9c` indigo | 5.29 → 6.96 |
| Constants | `@constant`, `@constant.builtin` (bold), numbers, booleans | `orange` `#b85600` | 4.58 → 4.61 |
| Strings | `@string` | `green` `#48682c` | 5.01 → 6.12 |
| Keywords | `@keyword` (italic) | `purple` `#7847bd` | 5.86 |
| Operators, delimiters | `@operator`, `@punctuation.delimiter` | `#005f76` | 5.94 → 6.95 |
| Brackets | `@punctuation.bracket` | `#5969a3` | 4.43 → 5.07 |
| Comments | `Comment` (italic) | `comment` `#636b94` | 3.15 → 4.96 |

`@module` moved off cyan to indigo so package qualifiers (`fmt.`, `os.`) no longer share a color with types.
Builtin constants moved from teal to bold orange so `nil`/`true` group with other constants.

## Language-specific groups

| Language | Groups | Decision |
|---|---|---|
| Go | `@type.builtin.go` bold `blue1`; `@module.go` indigo; `@lsp.typemod.variable.readonly.go` orange | gopls marks `const` as readonly, so Go constants turn orange. Scoped to Go: TS/JS servers mark every `const` local readonly, which flooded TS/JS with orange |
| Shell | `@variable.builtin.bash` bold red; `@punctuation.special.bash` bold orange; flags `@variable.parameter.bash` plain yellow | `$VAR` expansions stand out; flags read like parameters |
| JSON | keys `@property.json(c)` blue; booleans and `null` bold purple | Keys and string values no longer share green |
| jq | `@operator.jq` bold; `@property.jq` teal; `@variable.jq` orange | Pipeline structure is visible |
| Markdown | H1 blue, H2 purple, H3 teal, H4 orange, all bold, no pill (stock pills 2.80-3.60); inline code teal on `#eaecf4` (5.57, stock 1.68); link label blue underlined; URL `#636b94` underlined | Headings step through distinct hues |
| Python | `self`/`cls` italic red; decorators orange | |
| JS/TS/TSX | JSX components bold blue; `async`/`await` italic purple | Components are distinct from HTML tags |
| HTML/CSS | tags red, delimiters `#636b94`, attributes purple; CSS properties teal, numbers and units orange | CSS groups only take effect once the `css` Treesitter parser is installed |

## Editor surfaces (`on_highlights`)

| Group | Stock | New | Measured | Decision |
|---|---|---|---|---|
| `NormalFloat` | transparent | text `#2c3659` on `#f2f3f7` | 10.65 | Via `fg_float` / `bg_float`, not an override |
| `FloatBorder` | `#4094a3` | `#6f79a3` on `#f2f3f7` | 3.83 | Passes 3:1 on its own surface (first draft's `#8c96be` was 2.62) |
| `LineNr` (+ Above/Below) | `#a8aecb` | `#767ea6` | 2.10 → 3.79 | Darkened per group, not via `fg_gutter` |
| `Folded` | blue on `#a8aecb` | `#2a75da` on `#e6eaf5` | 1.83 → 3.75 | Soft band (1.15 vs canvas); first draft's gutter-colored band was 1.14 |
| `ColorColumn` (col 81) | `#b4b5b9` | `#ebedf5` | 1.96 → 1.12 vs canvas | Visible but quiet |
| `Pmenu` / `PmenuSel` | `#d0d5e3` / `#b3b8d1` | `#f1f2f7` / bold on `#c6cfe3` | text 7.55 on selection | Light menu, clearly marked row |
| `Visual` (+ NC/NOS) | `#b7c1e3` | `#c4d6ed` | 1.42 vs canvas, text 7.98 | Soft slate-blue that keeps syntax colors legible |
| `TreesitterContext` | `#b3b8d1` | `#ebedf5`, line numbers `#767ea6` (3.39), `#c6cfe3` underline | | Light sticky header that matches the gutter |
| `LspReference*`, `IlluminatedWord*`, `MiniCursorword*` | `fg_gutter` band | `#dfe4f2` read/text, `#d3dcf0` + blue underline write | text 9.28 / 8.58 | Stock was a mid-grey band |
| `Search` | `#3760bf` on `#7890dd` | `#5c4300` on `#f9eab0` | 1.90 → 7.72 | Pale gold pill for every match |
| `IncSearch` / `CurSearch` | `#b4b5b9` on `#b15c00` | `#fafafb` on `#937a00` | 2.33 → 4.01 | Solid gold pill for the current match |
| `LspInlayHint` | `#8990b3` on `#d9dce5` | `#636b94` on `#f1f2f7` | 2.29 → 4.63 | Readable but still secondary |
| `ComplHint` (ghost text) | `#a1a6c5` | `#636b94` | 2.29 → 4.96 | Same ink as comments |

### Diagnostics

| Severity | Text | Virtual-text pill (stock → new) |
|---|---|---|
| Error | `#c64343` 4.70 | `#ded2d7` 3.34 → `#f5e8e9` **4.11** |
| Warning | `#8c6c3e` 4.65 → `#937a00` 4.01 | `#d9d6d6` 3.36 → `#f0ede2` **3.57** |
| Info | `#07879d` 4.06 → `#067d92` 4.62 | `#cbd9e0` 2.93 → `#e2eef1` **4.07** |
| Hint | `#118c74` 4.00 → `#0f836c` 4.49 | `#ccd9dc` 2.89 → `#e3eeed` **3.95** |

All four pills come from the same 10% tint, re-based onto `#fafafb` (see step 3 under how tokyonight applies the
overrides). An earlier custom warning pill (`#6e5200` on `#fbf4d9`) was dropped so the four severities look alike.

## Terminal palette (`c.terminal`) and Ghostty

Neovim `:terminal` buffers and Ghostty use the same 16 colors, so shell output looks identical inside and outside
Neovim. Ratios are against `#fafafb`.

| ANSI | Normal | Ratio | ANSI | Bright | Ratio |
|---|---|---|---|---|---|
| 0 black | `#e4e6ee` | 1.19 (background tone) | 8 | `#5c638a` | 5.58 |
| 1 red | `#b83232` | 5.69 | 9 | `#dc2638` | 4.60 |
| 2 green | `#3d6324` | 6.69 | 10 | `#2d7a36` | 5.10 |
| 3 yellow | `#937a00` | 4.01 | 11 | `#b89c00` | 2.58 |
| 4 blue | `#2459b8` | 6.30 | 12 | `#226ae6` | 4.71 |
| 5 magenta | `#6b3fa8` | 6.94 | 13 | `#9838d9` | 5.16 |
| 6 cyan | `#006485` | 6.37 | 14 | `#007ca3` | 4.56 |
| 7 white | `#4b5680` | 6.84 | 15 | `#2c3659` | 11.32 |

As in stock TokyoNight Day, "black" is a light background tone and "white" is dark text, because the theme is
light. Bright yellow (11) is deliberately light and is the only text color below 3:1.

The Ghostty theme lives outside this repository, at `~/.config/ghostty/themes/tokyonight-day-crisp`, selected with
`theme = tokyonight-day-crisp` in `~/.config/ghostty/config`. Its full contents:

```ini
background = #fafafb
foreground = #2c3659
selection-background = #c4d6ed
selection-foreground = cell-foreground
palette = 0=#e4e6ee
palette = 1=#b83232
palette = 2=#3d6324
palette = 3=#937a00
palette = 4=#2459b8
palette = 5=#6b3fa8
palette = 6=#006485
palette = 7=#4b5680
palette = 8=#5c638a
palette = 9=#dc2638
palette = 10=#2d7a36
palette = 11=#b89c00
palette = 12=#226ae6
palette = 13=#9838d9
palette = 14=#007ca3
palette = 15=#2c3659
```

The palette is kept in two places. A change to `c.terminal`, `c.bg`, `c.fg` or `Visual` must be copied into the
Ghostty theme.

## Fixed during review

The first version of this config made claims that did not hold when measured:

| Problem | Effect | Fix |
|---|---|---|
| `hl.Normal = { bg = "none" }` (also `NormalNC`, `NormalFloat`) | Dropped the foreground: plain text and floats used Ghostty's text color instead of `#2c3659` | Removed; `transparent` already clears the background |
| `c.fg_gutter = "#767ea6"` | `Folded` became 1.14:1; indent guides and `listchars` turned heavy | `LineNr` groups instead |
| `c.red` / `c.yellow` changes assumed to recolor diagnostics | Warnings stayed brown | `c.warning = c.yellow` |
| Pills blended against stock `#e1e2e7` | Error/Info/Hint pills 2.9-3.3:1, inconsistent with the custom warning pill | Re-based `Util.bg` |
| `@lsp.typemod.variable.readonly` globally | Every TS/JS `const` turned orange | Scoped to Go |
| Stock baselines measured on `#e1e2e7` | Overstated gains ("doubles comments", "green failed AA") | All ratios re-measured on `#fafafb` |
| Misnamed colors in comments | `green1`, `blue1` and `blue` cited with wrong hex values | Corrected |
| `FloatBorder` "3.21:1" | Actually 2.62 on its float | `#6f79a3`, 3.83 |
| `c._style` check, cache clearing | `c._style` never exists; cache is off | Removed |
| Dark-mode overrides | Restated stock values; transparent float with an opaque border box | Removed: dark is stock Night |

## Open items and trade-offs

- **Parameters at 4.01:1** are below AA by choice (see [Yellow](#yellow)); 2.82:1 inside a selection.
- **Diff colors** (`DiffAdd` `#b6ccd3`, `DiffDelete` `#dababe`, …) are stock. tokyonight computes `c.diff` before
  `on_colors`, so re-basing them means recomputing `c.diff`.
- **`StatusLineNC`** is stock `#a8aecb` on `#cfd4e1` (1.48:1).
- **`DiagnosticUnnecessary`** (unused code) is stock `#a1a6c5` (2.29:1). It is meant to look faded.
- **`Util.bg`** is a tokyonight internal (see step 3 above).
- **ANSI 8 at 5.58:1** makes `zsh-autosuggestions` ghost text almost as dark as comments. If it is mistaken for
  typed text, set `ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8990b3"`.

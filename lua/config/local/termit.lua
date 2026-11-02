-- Termit: Lightweight, stateful terminal & floating CLI application manager
-- Features:
-- 1. Floating CLI tool window (default: lazygit via <leader>lg) with auto-centering
-- 2. Stateful side terminal split (<C-\>) that reuses buffers and remembers previous window
-- 3. Dedicated hide key (<C-]>) in terminal mode to dismiss windows without killing processes

local M = {}

-- State table: preserves buffer and window handles across open/close toggles
local state = {
	original = { buf = -1, win = -1 }, -- Window focused before opening terminal
	terminal = { buf = -1, win = -1 }, -- Active terminal buffer/window tracking
	split_term = { buf = -1, win = -1 }, -- Side split terminal window & buffer
	floating = { buf = -1, win = -1 }, -- Floating CLI window & buffer
}

-- Creates or reuses a centered floating window
local function create_floating_window(opts)
	opts = opts or {}

	vim.cmd("cd %:p:h") -- Set working directory to the current file's parent folder

	-- Calculate window dimensions based on editor size
	local width = opts.width or math.floor(vim.o.columns * 0.95)
	local height = opts.height or math.floor((vim.o.lines - 2) * 0.9)

	-- Center the floating window horizontally and vertically
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2) - 2

	-- Reuse existing buffer if valid, otherwise create a new unlisted buffer
	local buf = nil
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].swapfile = false
	end

	-- Window configuration with centered coordinates and borders
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = opts.border or "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

-- Toggles a floating window running a CLI app (e.g. lazygit)
local function toggle_floating_cliapp(opts)
	opts = opts or {}

	-- Save reference to existing terminal window if currently in one
	if state.terminal.win == -1 and vim.bo.buftype == "terminal" then
		state.terminal.win = vim.api.nvim_get_current_win()
		state.terminal.buf = vim.api.nvim_get_current_buf()
	end

	-- Clamp width and height percentages within safe bounds
	local w = math.min(math.max((opts.width or 0.95), 0.6), 1)
	local h = math.min(math.max((opts.height or 0.9), 0.6), 1)

	local width = math.floor(vim.o.columns * w)
	local height = math.floor((vim.o.lines - 2) * h)

	-- Minimum dimension safety check to prevent CLI app display errors
	if width < 85 or height < 23 then
		print("⚠️  Window is too small for floating cliapps!")
		if vim.api.nvim_win_is_valid(state.terminal.win) then
			vim.schedule(function()
				if vim.api.nvim_get_mode().mode ~= "i" then
					vim.cmd("startinsert")
				end
			end)
			state.terminal.win = -1
		end
		return
	end

	-- Leave terminal insert mode before opening float
	if vim.api.nvim_win_is_valid(state.terminal.win) then
		if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
			vim.cmd("stopinsert")
		end
	end

	-- Open window if closed, or hide if open
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({
			buf = state.floating.buf,
			width = width,
			height = height,
			border = opts.border,
		})

		-- Initialize CLI process inside buffer on first launch
		if vim.api.nvim_win_is_valid(state.floating.win) then
			if vim.bo[state.floating.buf].buftype ~= "terminal" then
				vim.cmd.terminal(opts.cliapp)
			end

			-- Focus and enter insert mode inside the terminal
			vim.schedule(function()
				if vim.api.nvim_get_mode().mode ~= "i" then
					vim.cmd("startinsert")
				end
			end)
		end
	else
		-- Hide floating window (process remains alive in buffer)
		vim.api.nvim_win_hide(state.floating.win)
		state.floating.win = -1

		-- Restore focus to previous terminal if applicable
		if vim.api.nvim_win_is_valid(state.terminal.win) then
			vim.schedule(function()
				if vim.api.nvim_get_mode().mode ~= "i" then
					vim.cmd("startinsert")
				end
			end)
			state.terminal.win = -1
		end
	end
end

-- Creates or reuses a side split window (automatically chooses vertical vs horizontal)
local function create_side_window(opts)
	opts = opts or {}

	vim.cmd("cd %:p:h")

	-- Clamp split proportions between 20% and 50%
	local w = math.min(math.max((opts.width or 0.34), 0.2), 0.5)
	local h = math.min(math.max((opts.height or 0.34), 0.2), 0.5)

	local width = math.floor(vim.o.columns * w)
	local height = math.floor((vim.o.lines - 2) * h)

	-- Reuse or create buffer
	local buf = nil
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].swapfile = false
	end

	-- If editor is wide enough (>59 cols), use vertical split; otherwise horizontal
	if width > 59 then
		vim.cmd("leftabove " .. width .. "vsplit")
	elseif height > 8 then
		vim.cmd("belowright " .. height .. "split")
	else
		print("⚠️  Window is too small to split!")
		return { win = -1, buf = -1 }
	end

	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	return { buf = buf, win = win }
end

-- Toggles side terminal split, switching focus back and forth between code and shell
local function toggle_side_term(opts)
	opts = opts or {}

	local win = vim.api.nvim_get_current_win()

	-- Remember original code window before focusing split
	if state.split_term.win == -1 and win ~= state.floating.win then
		state.original.win = win
	end

	-- Open split if not open, or cycle focus between code and terminal
	if not vim.api.nvim_win_is_valid(state.split_term.win) then
		state.split_term = create_side_window({
			buf = state.split_term.buf,
			width = opts.width,
			height = opts.height,
		})

		if vim.api.nvim_win_is_valid(state.split_term.win) then
			-- Start shell if buffer is fresh
			if vim.bo[state.split_term.buf].buftype ~= "terminal" then
				vim.cmd.terminal(vim.o.shell)
			end
			if vim.api.nvim_get_mode().mode ~= "i" then
				vim.cmd("startinsert")
			end
		end
	elseif win == state.split_term.win then
		-- If inside terminal split, switch focus back to original code window
		if vim.api.nvim_win_is_valid(state.original.win) then
			vim.api.nvim_set_current_win(state.original.win)
		end
	elseif win == state.original.win then
		-- If in original window, switch focus into the open terminal split
		if vim.api.nvim_win_is_valid(state.split_term.win) then
			vim.api.nvim_set_current_win(state.split_term.win)
			if vim.api.nvim_get_mode().mode ~= "i" then
				vim.cmd("startinsert")
			end
		end
	end
end

-- Hides whichever terminal window (side split or floating) currently has focus
local function hide_terminal()
	local win = vim.api.nvim_get_current_win()
	if win == state.split_term.win then
		vim.api.nvim_win_hide(win)
		state.split_term.win = -1
	elseif win == state.floating.win then
		vim.api.nvim_win_hide(win)
		state.floating.win = -1
	end
end

-- Public setup function: merges configuration options and sets keymaps
function M.setup(opts)
	opts = opts or {}

	local keymaps = vim.tbl_deep_extend("force", {
		toggle_terminal = "<C-\\>",
		toggle_lazygit = (opts.keymaps and (opts.keymaps.toggle_lazygit or opts.keymaps.toggle_floating_cliapp))
			or "<leader>lg",
		hide_terminal = "<C-]>",
	}, opts.keymaps or {})

	local floating = vim.tbl_deep_extend("force", {
		width = 0.95,
		height = 0.9,
		cliapp = "lazygit",
		border = "rounded",
	}, opts.floating or {})

	local side_term = vim.tbl_deep_extend("force", {
		width = 0.34,
		height = 0.34,
	}, opts.side_term or {})

	-- Toggle side terminal split: Normal mode (<C-\>)
	vim.keymap.set("n", keymaps.toggle_terminal, function()
		toggle_side_term({ width = side_term.width, height = side_term.height })
	end, {
		desc = "Toggle terminal split",
		silent = true,
	})

	-- Guard terminal mode keymaps: prevent registering <leader> or <Space>-prefixed keys in "t" mode
	local is_space_leader = function(key)
		if not key or type(key) ~= "string" then
			return false
		end
		local lower = key:lower()
		return lower:match("^<space>") or lower:match("^<leader>") or key:sub(1, 1) == " "
	end

	-- Toggle side terminal split from terminal mode (single chords only)
	if not is_space_leader(keymaps.toggle_terminal) then
		vim.keymap.set("t", keymaps.toggle_terminal, function()
			toggle_side_term({ width = side_term.width, height = side_term.height })
		end, {
			desc = "Toggle terminal split from terminal mode",
			silent = true,
		})
	else
		vim.notify(
			"[termit] Cannot bind '"
				.. keymaps.toggle_terminal
				.. "' in terminal mode: <Space>/<leader> prefix introduces typing delay.",
			vim.log.levels.WARN
		)
	end

	-- Toggle floating LazyGit window (<leader>lg in Normal mode)
	vim.keymap.set("n", keymaps.toggle_lazygit, function()
		toggle_floating_cliapp({
			width = floating.width,
			height = floating.height,
			cliapp = floating.cliapp,
			border = floating.border,
		})
	end, {
		desc = "Toggle lazygit floating window",
		silent = true,
	})

	-- Hide terminal from inside terminal mode (<C-]> single chord)
	if not is_space_leader(keymaps.hide_terminal) then
		vim.keymap.set("t", keymaps.hide_terminal, hide_terminal, {
			desc = "Hide terminal split",
			silent = true,
		})
	else
		vim.notify(
			"[termit] Cannot bind '"
				.. keymaps.hide_terminal
				.. "' in terminal mode: <Space>/<leader> prefix introduces typing delay.",
			vim.log.levels.WARN
		)
	end
end

return M

local M = {}

local state = {
	original = { buf = -1, win = -1 },
	terminal = { buf = -1, win = -1 },
	split_term = { buf = -1, win = -1 },
	floating = { buf = -1, win = -1 },
}

local function create_floating_window(opts)
	opts = opts or {}

	vim.cmd("cd %:p:h") -- Sets current directory for a buffer

	-- Calculate the width and height of the window
	local width = opts.width or math.floor(vim.o.columns * 0.95)
	local height = opts.height or math.floor((vim.o.lines - 2) * 0.9)

	-- Center the window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2) - 2

	-- Create or reuse buffer
	local buf = nil
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].swapfile = false
	end

	-- Create window with specific options
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

-- Open a floating terminal with lazygit in it
local function toggle_floating_cliapp(opts)
	opts = opts or {}

	if state.terminal.win == -1 and vim.bo.buftype == "terminal" then
		state.terminal.win = vim.api.nvim_get_current_win()
		state.terminal.buf = vim.api.nvim_get_current_buf()
	end

	-- If the width is out of bounds or too small use fixed sizes
	local w = math.min(math.max((opts.width or 0.95), 0.6), 1)

	-- If the height is out of bounds or too small use fixed sizes
	local h = math.min(math.max((opts.height or 0.9), 0.6), 1)

	-- Calculate the width and height of the window
	local width = math.floor(vim.o.columns * w)
	local height = math.floor((vim.o.lines - 2) * h)

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

	-- Exit terminal if we are in a terminal buffer
	if vim.api.nvim_win_is_valid(state.terminal.win) then
		if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
			vim.cmd("stopinsert")
		end
	end

	-- Toggle floating window
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({
			buf = state.floating.buf,
			width = width,
			height = height,
			border = opts.border,
		})

		-- Check if window was created
		if vim.api.nvim_win_is_valid(state.floating.win) then
			-- If the buffer is not terminal - start the terminal and lazygit
			if vim.bo[state.floating.buf].buftype ~= "terminal" then
				vim.cmd.terminal(opts.cliapp)
			end

			vim.schedule(function()
				if vim.api.nvim_get_mode().mode ~= "i" then
					vim.cmd("startinsert")
				end
			end)
		end
	else -- Hide the floating window
		vim.api.nvim_win_hide(state.floating.win)
		state.floating.win = -1

		-- Check if the previous window was terminal
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

local function create_side_window(opts)
	opts = opts or {}

	vim.cmd("cd %:p:h") -- Sets current directory for a buffer

	-- If the width is bigger than the window or too small use fixed sizes
	local w = math.min(math.max((opts.width or 0.34), 0.2), 0.5)

	-- If the height is bigger than the window or too small use fixed sizes
	local h = math.min(math.max((opts.height or 0.34), 0.2), 0.5)

	local width = math.floor(vim.o.columns * w)
	local height = math.floor((vim.o.lines - 2) * h)

	-- Create or reuse buffer
	local buf = nil
	if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "hide"
		vim.bo[buf].swapfile = false
	end

	-- If the window is too narrow choose horizontal split
	if width > 59 then -- Vertical split
		vim.cmd("leftabove " .. width .. "vsplit")
	elseif height > 8 then -- Horizontal split
		vim.cmd("belowright " .. height .. "split")
	else
		print("⚠️  Window is too small to split!")
		return { win = -1, buf = -1 }
	end

	local win = vim.api.nvim_get_current_win()

	vim.api.nvim_win_set_buf(win, buf)

	return { buf = buf, win = win }
end

local function toggle_side_term(opts)
	opts = opts or {}

	local win = vim.api.nvim_get_current_win()

	if state.split_term.win == -1 and win ~= state.floating.win then
		state.original.win = win
	end

	if not vim.api.nvim_win_is_valid(state.split_term.win) then
		state.split_term = create_side_window({
			buf = state.split_term.buf,
			width = opts.width,
			height = opts.height,
		})

		-- Check if window was created
		if vim.api.nvim_win_is_valid(state.split_term.win) then
			if vim.bo[state.split_term.buf].buftype ~= "terminal" then
				vim.cmd.terminal(vim.o.shell)
			end
			if vim.api.nvim_get_mode().mode ~= "i" then
				vim.cmd("startinsert")
			end
		end
	elseif win == state.split_term.win then
		if vim.api.nvim_win_is_valid(state.original.win) then
			vim.api.nvim_set_current_win(state.original.win)
		end
	elseif win == state.original.win then
		if vim.api.nvim_win_is_valid(state.split_term.win) then
			vim.api.nvim_set_current_win(state.split_term.win)
			if vim.api.nvim_get_mode().mode ~= "i" then
				vim.cmd("startinsert")
			end
		end
	end
end

local function hide_terminal()
	local win = vim.api.nvim_get_current_win()
	-- Check which window are we hiding
	if win == state.split_term.win then
		vim.api.nvim_win_hide(win)
		state.split_term.win = -1
	elseif win == state.floating.win then
		vim.api.nvim_win_hide(win)
		state.floating.win = -1
	end
end

function M.setup(opts)
	opts = opts or {}

	local keymaps = vim.tbl_deep_extend("force", {
		toggle_terminal = "<C-\\>",
		toggle_floating_cliapp = "<C-G>",
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

	vim.keymap.set({ "n", "t" }, keymaps.toggle_terminal, function()
		toggle_side_term({ width = side_term.width, height = side_term.height })
	end, {
		desc = "Toggle terminal split",
		silent = true,
	})

	vim.keymap.set({ "n", "t" }, keymaps.toggle_floating_cliapp, function()
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

	vim.keymap.set("t", keymaps.hide_terminal, hide_terminal, {
		desc = "Hide terminal split",
		silent = true,
	})
end

return M

local M = {}

local log = require("plenary.log").new({ plugin = "termui", level = "debug" })
-- tail -f ~/.local/state/nvim/termui.log

local separator =
	"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
local indent = "┃ "
local indent2 = "┗━"

-- ------------------------------------------------------------
-- Manager "class"
-- ------------------------------------------------------------
local Manager = {}
Manager.__index = Manager

-- Sets the metatable for a Manager instance
-- @return the Manager instance
function Manager.new()
	return setmetatable({
		terms = {}, -- { { buf=number, job=number, cwd=string, name=string } }
		current = nil, -- selected index
		ui_win = nil,
		ui_buf = nil,
		term_win = nil,
		ns = vim.api.nvim_create_namespace("termui"),
		header_lines = 5, -- number of non-terminal lines at top of list
	}, Manager)
end

function Manager:is_valid()
	return self.ui_win and vim.api.nvim_win_is_valid(self.ui_win)
end

function Manager:term_line_start()
	return self.header_lines + 1
end

function Manager:row_to_index(row)
	local start = self:term_line_start()
	local idx = row - start + 1 -- +1 because tables are 1 indexed
	if idx < 1 or idx > #self.terms then
		return nil
	end
	return idx
end

function Manager:index_to_row(idx)
	-- -1 because tables are 1 indexed
	return self:term_line_start() + idx - 1
end

-- Renders the TermUI list buffer
function Manager:render()
	if not self.ui_buf or not vim.api.nvim_buf_is_valid(self.ui_buf) then
		log.error("render: ui_buf not valid")
		return
	end

	local lines = {
		indent .. "Terminal UI",
		indent2 .. separator,
		"j/k move",
		"<CR> select   o new   d delete at cursor   q quit",
		"",
	}

	if #self.terms == 0 then
		table.insert(lines, indent .. "(no terminals)")
	else
		for i, t in ipairs(self.terms) do
			local mark = (self.current == i) and ">" or " "
			local name = t.name or ("term " .. i)
			local cwd = t.cwd or ""
			table.insert(lines, string.format("%s%s [%d] %s  %s", " ", mark, i, name, cwd))
		end
	end

	vim.bo[self.ui_buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.ui_buf, 0, -1, false, lines)
	vim.bo[self.ui_buf].modifiable = false

	-- Clear + set a simple highlight for the selected line
	vim.api.nvim_buf_clear_namespace(self.ui_buf, self.ns, 0, -1)
	if self.current then
		local row = self:index_to_row(self.current)
		vim.api.nvim_buf_add_highlight(self.ui_buf, self.ns, "Visual", row - 1, 0, -1)
	end
end

-- Selects a terminal index and renders
function Manager:select(idx)
	if not idx or not self.terms[idx] then
		return
	end
	if not self.term_win or not vim.api.nvim_win_is_valid(self.term_win) then
		return
	end

	self.current = idx
	local buf = self.terms[idx].buf
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_win_set_buf(self.term_win, buf)
	end
	self:render()
end

function Manager:new_terminal(cwd)
	cwd = cwd or vim.fn.getcwd()

	-- Create a hidden listed=false scratch buffer that will host the terminal
	local buf = vim.api.nvim_create_buf(false, true)
	-- vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "TermUITerminal"

	-- Start terminal job inside that buffer
	local job_id
	vim.api.nvim_buf_call(buf, function()
		local shell = vim.o.shell or vim.env.SHELL or "sh"
		local is_fish = shell:match("fish$") ~= nil

		local bash_init = [[
print_osc7() { printf '\033]7;file://%s\033\\' "$PWD"; }

# keep any existing PROMPT_COMMAND
PROMPT_COMMAND="print_osc7${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# make it survive into the next bash started by exec
export PROMPT_COMMAND
export -f print_osc7

exec "$SHELL" -i
]]

		local fish_init = [[
function __print_osc7
  printf '\e]7;file://%s\e\\' (pwd)
end

# Preserve existing fish_prompt by renaming it, then wrap it.
if functions -q fish_prompt
  functions --copy fish_prompt __orig_fish_prompt
  functions --erase fish_prompt
else
  function __orig_fish_prompt
  end
end

function fish_prompt
  __print_osc7
  __orig_fish_prompt
end

exec fish -i
]]

		local argv = is_fish and { shell, "-ic", fish_init } or { shell, "-ic", bash_init }

		job_id = vim.fn.jobstart(argv, { term = true, cwd = cwd })
	end)

	local idx = #self.terms + 1 -- +1 because tables are 1 indexed
	table.insert(self.terms, {
		buf = buf,
		job = job_id,
		cwd = cwd,
		name = "",
	})

	self.current = idx
	self:render()
	self:select(idx)
end

-- Closes the terminal at the index
function Manager:close_terminal(idx)
	local t = self.terms[idx]
	if not t then
		return
	end

	if t.job and t.job > 0 then
		pcall(vim.fn.jobstop, t.job)
	end
	if t.buf and vim.api.nvim_buf_is_valid(t.buf) then
		pcall(vim.api.nvim_buf_delete, t.buf, { force = true })
	end

	table.remove(self.terms, idx)

	if #self.terms == 0 then
		self.current = nil
	else
		if not self.current then
			self.current = 1
		else
			self.current = math.min(self.current, #self.terms)
		end
	end

	self:render()
	if self.current then
		self:select(self.current)
		-- keep cursor aligned with selection if possible
		local row = self:index_to_row(self.current)
		pcall(vim.api.nvim_win_set_cursor, self.ui_win, { row, 0 })
	end
end

function Manager:quit()
	if self.ui_win and vim.api.nvim_win_is_valid(self.ui_win) then
		local tab = vim.api.nvim_win_get_tabpage(self.ui_win)
		pcall(vim.api.nvim_tabpage_close, tab, true)
	end
end

-- ------------------------------------------------------------
-- Module singleton (simple for learning)
-- ------------------------------------------------------------
local manager = nil

-- ------------------------------------------------------------
-- Public entry
-- ------------------------------------------------------------
function M.open()
	manager = Manager.new()

	vim.cmd("tabnew")
	pcall(vim.cmd, "Tabby rename_tab Terminals")

	vim.cmd("vsplit")
	vim.cmd("wincmd h")
	manager.ui_win = vim.api.nvim_get_current_win()

	-- list buffer
	local list_buf = vim.api.nvim_create_buf(false, true)
	manager.ui_buf = list_buf

	pcall(vim.api.nvim_buf_set_name, list_buf, "TermUIList")
	vim.bo[list_buf].buftype = "nofile"
	vim.bo[list_buf].filetype = "TermUIList"
	vim.bo[list_buf].bufhidden = "hide"
	vim.bo[list_buf].swapfile = false
	vim.bo[list_buf].modifiable = false

	vim.api.nvim_win_set_buf(manager.ui_win, list_buf)

	-- right window for terminals
	vim.cmd("wincmd l")
	manager.term_win = vim.api.nvim_get_current_win()

	-- keymaps (buffer-local)
	local function map(lhs, rhs)
		vim.keymap.set("n", lhs, rhs, { buffer = list_buf, nowait = true, silent = true })
	end

	map("o", function()
		manager:new_terminal(vim.fn.getcwd())
	end)

	map("<CR>", function()
		local row = vim.api.nvim_win_get_cursor(manager.ui_win)[1]
		local idx = manager:row_to_index(row)
		if idx then
			log.debug("<CR> detected. row: " .. row .. " selecting idx: " .. idx)
			manager:select(idx)
		else
			log.debug("<CR> detected. row: " .. row .. ". No terminal at this row")
		end
	end)

	map("d", function()
		local row = vim.api.nvim_win_get_cursor(manager.ui_win)[1]
		local idx = manager:row_to_index(row)
		if idx then
			log.debug("d detected. row: " .. row .. " deleting idx: " .. idx)
			manager:close_terminal(idx)
		else
			log.debug("d detected. row: " .. row .. ". No terminal at this row")
		end
	end)

	map("q", function()
		manager:quit()
	end)

	-- cursor-moved selection behavior
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = list_buf,
		callback = function()
			if not manager or not manager:is_valid() then
				return
			end
			local row = vim.api.nvim_win_get_cursor(manager.ui_win)[1]
			local idx = manager:row_to_index(row)
			if idx and idx ~= manager.current then
				manager:select(idx)
			end
		end,
	})

	vim.api.nvim_create_autocmd("TermRequest", {
		desc = "TermUI: track OSC 7 cwd per terminal buffer",
		callback = function(ev)
			local val, n = string.gsub(ev.data.sequence, "\027]7;file://[^/]*", "")
			log.debug("chdir TermRequest val: " .. val .. " n: " .. n)
			if n > 0 then
				local dir = val
				if vim.fn.isdirectory(dir) == 0 then
					return
				end

				vim.b[ev.buf].osc7_dir = dir

				if not manager or not manager:is_valid() then
					return
				end

				for _, t in ipairs(manager.terms) do
					if t.buf == ev.buf then
						t.cwd = dir
						break
					end
				end
				manager:render()
			end
		end,
	})

	vim.notify(vim.fn.stdpath("cache"))

	manager:render()
	-- Optionally create an initial terminal
	manager:new_terminal(vim.fn.getcwd())

	-- put cursor onto the first terminal line (after header)
	-- if manager.current then
	-- 	local row = manager:index_to_row(manager.current)
	-- 	pcall(vim.api.nvim_win_set_cursor, manager.ui_win, { row, 0 })
	-- end
end

function M.setup(opts)
	opts = opts or {}
	if opts.log_level then
		log = require("plenary.log").new({ plugin = "termui", level = opts.log_level })
	end
end

return M

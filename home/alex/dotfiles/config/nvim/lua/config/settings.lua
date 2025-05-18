-- User options
-- https://neovim.io/doc/user/options.html

vim.o.updatetime = 300 -- Faster hover time (4000ms default)
vim.o.number = true -- Show absolute line number on the current line
vim.o.relativenumber = true -- Show relative line numbers on all other lines

-- 4 spaces for indents
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

vim.o.smartindent = false

-- Turn off backups but enable long lasting for undo
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

-- Highlight and incremental search
vim.o.hlsearch = true
vim.o.incsearch = true

-- Colors
vim.o.termguicolors = true

-- Lines at the bottom
vim.o.scrolloff = 8
vim.o.signcolumn = "yes"

vim.o.updatetime = 50

vim.o.colorcolumn = "80"

-- Dagnostic settings
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	underline = true,
	float = {
		border = "single",
		source = true,
		max_width = 100,
		header = "Diagnostics",
		prefix = "● ",
	},
})

-- Add the tabline for harpoon tabs
vim.o.showtabline = 2
-- vim.o.tabline = "%!v:lua.HarpoonTabline()"

function _G.HarpoonTabline()
	local harpoon = require("harpoon"):list()
	local tabline = ""

	local function normalize(path)
		return vim.loop.fs_realpath(path)
	end

	local current_buf = vim.api.nvim_get_current_buf()
	local current_file = normalize(vim.api.nvim_buf_get_name(current_buf))

	if harpoon.items then
		for i, item in ipairs(harpoon.items) do
			local full_path = normalize(item.value) or item.value
			local relative_path = vim.fn.fnamemodify(item.value, ":.")

			local is_active = (full_path == current_file)

			local hl = is_active and "%#TabLineSel#" or "%#TabLine#"
			tabline = tabline .. hl .. " " .. i .. ". " .. relative_path .. " " .. "%T"
		end
	end

	tabline = tabline .. "%#TabLineFill#%="

	return tabline
end

-- Allow local configuration
vim.o.exrc = true
vim.o.secure = false

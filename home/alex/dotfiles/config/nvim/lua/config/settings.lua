-- User options
-- https://neovim.io/doc/user/options.html

vim.o.updatetime = 300      -- Faster hover time (4000ms default)
vim.o.number = true         -- Show absolute line number on the current line
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

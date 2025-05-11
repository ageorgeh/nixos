-- init.lua

vim.g.mapleader = " "

require("config.lazy")
require("config.keymaps")


-- vim.o.termguicolors = true
vim.cmd("colorscheme rose-pine")
-- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
-- vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")

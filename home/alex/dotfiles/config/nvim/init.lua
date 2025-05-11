-- init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.env.NVIM_LISTEN_ADDRESS = "/tmp/nvimsocket"



require("config.lazy")
require("config.keymaps")

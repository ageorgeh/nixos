-- init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername

require("config.lazy")
require("config.keymaps")
require("config.settings")
require("config.lsp")

require("config.filetype")

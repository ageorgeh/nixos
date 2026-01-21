-- init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.env.NVIM_LISTEN_ADDRESS = vim.v.servername

require("config.lazy")
require("config.keymaps")
require("config.settings")
require("config.lsp")

require("config.filetype")

-- vim.api.nvim_create_autocmd("BufWritePost", {
--     pattern = "tabby.lua",
--     -- command = "Lazy reload tabby.nvim"
--     command = "ls"
-- })

vim.api.nvim_create_autocmd("User", {
    pattern = "LazyReload",
    callback = function()
        vim.cmd("silent! Lazy reload tabby.nvim")
    end,
})

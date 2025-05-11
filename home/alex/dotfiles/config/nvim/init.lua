-- init.lua

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.env.NVIM_LISTEN_ADDRESS = "/tmp/nvimsocket"



require("config.lazy")
require("config.keymaps")

vim.lsp.config("luals", require("lsp.luals"))
vim.lsp.enable('luals')
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

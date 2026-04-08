-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Plugin for displaying markdown nicely inside NVIM
-- This could be a nice complement https://github.com/iamcco/markdown-preview.nvim

return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    config = function()
        require('render-markdown').setup({
            completions = { lsp = { enabled = true } },
        })
    end
}

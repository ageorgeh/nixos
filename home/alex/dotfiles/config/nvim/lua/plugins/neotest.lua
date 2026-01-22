return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",

        "marilari88/neotest-vitest",
    },
    config = function()
        local neotest = require("neotest")

        neotest.setup({
            adapters = {
                require("neotest-vitest")({
                }),
            },
            -- https://github.com/nvim-neotest/neotest/blob/master/doc/neotest.txt#L133
            output_panel = {
                open = 'botright vsplit | vertical resize 80'
            }
        })
    end,
}

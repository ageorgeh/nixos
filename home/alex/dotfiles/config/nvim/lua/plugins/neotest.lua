return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",

        "marilari88/neotest-vitest",
        "thenbe/neotest-playwright"
    },
    config = function()
        local neotest = require("neotest")

        neotest.setup({
            adapters = {
                require("neotest-vitest")({
                    vitestCommand = "pnpm test"
                }),
                require('neotest-playwright').adapter({
                    command = "pnpm test:e2e",
                }),
            },
            -- https://github.com/nvim-neotest/neotest/blob/master/doc/neotest.txt#L133
            output_panel = {
                open = 'botright vsplit | vertical resize 80'
            }
        })
    end,
}

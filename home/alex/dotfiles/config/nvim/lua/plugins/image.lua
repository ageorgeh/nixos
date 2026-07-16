-- return {
--     "3rd/image.nvim",
--     dependencies = { "nvim-lua/plenary.nvim" },
--     build = false,
--     opts = {
--         backend = "kitty",
--         processor = "magick_cli",
--     },
-- }


-- Works better than image.nvim
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        image = {},
        terminal = {}
    },
}

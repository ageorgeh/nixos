-- lua/plugins/rose-pine.lua
-- https://rosepinetheme.com/palette/
return {
    "rose-pine/neovim",
    lazy = false,
    priority = 1000,
    name = "rose-pine",
    config = function()
        require("rose-pine").setup({
            dim_inactive_windows = true,
            styles = {
                transparency = true
            },
        })
        vim.cmd("colorscheme rose-pine")
        vim.api.nvim_set_hl(0, "NormalNC", {
            bg = "NONE",
            fg = "#6e6a86",
        })
    end
}

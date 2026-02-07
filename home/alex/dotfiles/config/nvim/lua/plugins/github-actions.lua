-- Provides a view for github actions runs
return {
    "jaklimoff/github-actions.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        require("github-actions").setup({
            debug = false,
            telescope_limit = 30,
        })
    end,
}

-- https://github.com/pwntester/octo.nvim
-- Plugin for interacting with github from nvim

return {
    "pwntester/octo.nvim",
    cmd = "Octo",
    opts = {
        -- or "fzf-lua" or "snacks" or "default"
        picker = "telescope",
        -- bare Octo command opens picker of commands
        enable_builtin = true,
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
}

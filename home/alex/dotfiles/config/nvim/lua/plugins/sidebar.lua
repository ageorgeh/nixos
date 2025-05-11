return {
    -- nvim-tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                update_cwd = true,
                respect_buf_cwd = true,
            })
        end,
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle NvimTree" },
        },
    },

    -- oil.nvim
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = false, -- <-- prevent it from overriding nvim-tree
            })
        end,
        keys = {
            { "-", function() require("oil").open() end, desc = "Open parent directory in Oil" },
        },
    }
}

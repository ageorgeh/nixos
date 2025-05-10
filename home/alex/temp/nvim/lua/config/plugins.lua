return {
    -- Colorscheme
    {
        "rose-pine/neovim",
        name = "rose-pine"
    },

    -- UI
    "nvim-lualine/lualine.nvim",
    "nvim-tree/nvim-web-devicons",

    -- LSP and completion
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },

}

return {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPre",
    config = function()
        require("treesitter-context").setup({
            enable = true,
            -- max_lines = 3,        -- how many lines of context to show
            -- trim_scope = "outer", -- can be 'inner' or 'outer'
        })
        vim.cmd("hi TreesitterContextLineNumberBottom gui=underline guisp=#f6c177")
    end
}

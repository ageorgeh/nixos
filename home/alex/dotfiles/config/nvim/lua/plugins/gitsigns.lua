-- Provides gutter view for git changes
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signcolumn = true,
        numhl = true, -- highlight line numbers for changed lines
        linehl = false,
        word_diff = false,
        current_line_blame = false,
    },
}

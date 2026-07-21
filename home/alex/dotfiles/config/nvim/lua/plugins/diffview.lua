-- Provides a vscode like sidebar diff view

return {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
        keymaps = {
            view = {
                toggle_stage = "s", -- Stage/unstage current file (works in explorer and diff buffers)
            }
        },
        explorer = {
            -- auto_refresh = false,
            view_mode = "tree",
        },
        diff = {
            -- compute_moves = false,
        },
    },
}

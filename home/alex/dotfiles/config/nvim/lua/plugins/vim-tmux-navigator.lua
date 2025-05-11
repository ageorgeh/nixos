return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
    },
    keys = {
        { "<M-h>",  ":TmuxNavigateLeft<CR>",     mode = "n" },
        { "<M-j>",  ":TmuxNavigateDown<CR>",     mode = "n" },
        { "<M-k>",  ":TmuxNavigateUp<CR>",       mode = "n" },
        { "<M-l>",  ":TmuxNavigateRight<CR>",    mode = "n" },
        { "<C-\\>", ":TmuxNavigatePrevious<CR>", mode = "n" },
    },
}

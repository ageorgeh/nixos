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
    init = function()
        -- Custom key binds (alt instead of ctrl)
        vim.g.tmux_navigator_no_mappings = 1
    end
}

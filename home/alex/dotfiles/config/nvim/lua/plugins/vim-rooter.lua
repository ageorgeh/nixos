return {
    -- Changes cwd to project root when opening a file
    "airblade/vim-rooter",
    init = function()
        vim.g.rooter_change_directory_for_non_project_files = 'current' -- fallback to file dir
        vim.g.rooter_cd_cmd = 'tcd'                                     -- use tab-local working directory
    end
}

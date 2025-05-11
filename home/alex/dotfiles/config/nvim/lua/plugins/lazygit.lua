-- nvim v0.8.0
return {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    },
    config = function()
        vim.api.nvim_create_autocmd("TermOpen", {
            callback = function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if bufname:match("lazygit") then
                    vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true, noremap = true })
                end
            end,
        })
    end
}

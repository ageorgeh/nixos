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
    config = function()
        vim.api.nvim_create_autocmd("TermOpen", {
            callback = function()
                -- Sends <Esc> to lazy git when using it (so it doesn't just take us to normal mode)
                local bufname = vim.api.nvim_buf_get_name(0)
                if bufname:match("lazygit") then
                    vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = true, noremap = true })
                end
            end,
        })
    end
}

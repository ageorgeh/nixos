-- Provides a vscode like sidebar diff view


local function goto_file_vsplit()
    local lib = require("diffview.lib")
    local view = lib.get_current_view()
    if not view then return end

    local file = view:infer_cur_file()
    if not file then return end

    vim.cmd("vnew")
    local tmp = vim.api.nvim_get_current_buf()

    file.layout:restore_winopts()
    vim.cmd("keepalt edit " .. vim.fn.fnameescape(file.absolute_path))

    if tmp ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_buf_delete(tmp, { force = true })
    end
end

return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = {
        file_panel = {
            listing_style = "tree",
            win_config = {
                position = "left",
                width = 35,
            },
        },
    },
    config = function()
        require("diffview").setup({
            keymaps = {
                file_panel = {
                    { "n", "<C-w><C-v>", goto_file_vsplit, { desc = "Open file in vertical split" } },
                },
                view = {
                    { "n", "<C-w><C-v>", goto_file_vsplit, { desc = "Open file in vertical split" } },
                },
            },
        })
    end
}

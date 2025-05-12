-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Git files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })

-- Alt for splitting same as in my tmux
vim.keymap.set("n", "<M-->", "<cmd>split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<M-\\>", "<cmd>vsplit<CR>", { desc = "Vertical Split" })

-- Exit terminal mode with <Esc>
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Resize same as tmux but for vim panes
vim.keymap.set("n", "<C-M-h>", "<cmd>vertical resize -5<CR>", { desc = "Resize split left" })
vim.keymap.set("n", "<C-M-l>", "<cmd>vertical resize +5<CR>", { desc = "Resize split right" })
vim.keymap.set("n", "<C-M-k>", "<cmd>resize -5<CR>", { desc = "Resize split up" })
vim.keymap.set("n", "<C-M-j>", "<cmd>resize +5<CR>", { desc = "Resize split down" })


-- Undotree
vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Toggle Undotree" })

-- LazyGit
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

---------------------- LSP ----------------------
-- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()
vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover { border = "rounded", max_height = 25, title = "Hover" }
end)


-- Moving highlighted blocks around with shift + j|k
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


-- Cursor in center with half page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- And search
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")


-- Paste over something but keep the same buffer
vim.keymap.set("x", "<leader>p", "\"_dP")


-- Copy to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")


-- Leader x to make executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x $<CR>", { silent = true })

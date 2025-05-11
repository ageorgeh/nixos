-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find Help" })

-- Alt for splitting same as in my tmux
vim.keymap.set("n", "<M-->", "<cmd>split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<M-\\>", "<cmd>vsplit<CR>", { desc = "Vertical Split" })

-- Exit terminal mode with <Esc>
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-M-h>", "<cmd>vertical resize -5<CR>", { desc = "Resize split left" })
vim.keymap.set("n", "<C-M-l>", "<cmd>vertical resize +5<CR>", { desc = "Resize split right" })
vim.keymap.set("n", "<C-M-k>", "<cmd>resize -5<CR>", { desc = "Resize split up" })
vim.keymap.set("n", "<C-M-j>", "<cmd>resize +5<CR>", { desc = "Resize split down" })

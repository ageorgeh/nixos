-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fc", function()
	require("telescope.builtin").find_files({
		prompt_title = "Find in ~/code",
		cwd = "~/code",
		hidden = true, -- optional: include dotfiles
	})
end, { desc = "Find files in ~/code" })
vim.keymap.set("n", "<leader>gc", function()
	require("telescope.builtin").live_grep({
		prompt_title = "Grep in ~/code",
		cwd = "~/code",
	})
end, { desc = "Grep in ~/code" })

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

vim.keymap.set("n", "<leader>tw", function()
	local bufdir = vim.fn.expand("%:p:h")
	local cmd = string.format('tmux new-window -c "%s"', bufdir)
	os.execute(cmd)
end, { desc = "Open tmux window in buffer's directory" })

-- Nvim-tree
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeFindFile<cr>", { desc = "Toggle NvimTree" })

-- Undotree
vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Toggle Undotree" })

-- Tmux navigator
vim.keymap.set("n", "<M-h>", ":<C-U>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<M-j>", ":<C-U>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<M-k>", ":<C-U>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<M-l>", ":<C-U>TmuxNavigateRight<CR>")
vim.keymap.set("n", "<C-\\>", ":<C-U>TmuxNavigatePrevious<CR>")

-- LazyGit
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

---------------------- LSP ----------------------
-- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.hover()
vim.keymap.set("n", "K", function()
	vim.lsp.buf.hover({ border = "rounded", max_height = 25, title = "Hover" })
end)

-- C-] Jump to definition. C-t to go back
-- C-x C-o Trigger code completion menu
-- [-d and ]-d to move the cursor to previous / next errors
-- grn renames all references of the symbol under the cursor
-- grr lists all references of the symbol under the cursor
-- gri lists the implementations for the symbol under the cursor
-- C-s in insert mode displays the function signature of the symbol under the cursor

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
vim.keymap.set("x", "<leader>p", '"_dP')

-- Copy to system clipboard
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Leader x to make executable
vim.keymap.set("n", "<leader>x", function()
	vim.cmd("!chmod +x " .. vim.fn.expand("%"))
	vim.cmd("echo 'Made executable: " .. vim.fn.expand("%") .. "'")
end, { silent = true })

-- Harpoon
local harpoon = require("harpoon")
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do
		table.insert(file_paths, item.value)
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "Harpoon",
			finder = require("telescope.finders").new_table({
				results = file_paths,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
		})
		:find()
end

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Open harpoon window" })

vim.keymap.set("n", "<C-h>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-j>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-k>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-l>", function()
	harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

-- Nvim Tree TODO
-- Find and focus directory
-- Move functions pertaining to key commands to lua/utils/...

-- Formatting
vim.keymap.set("n", "<leader>lf", function()
	require("conform").format({ async = true, lsp_fallback = true })
end)

-- Tabs
vim.keymap.set("n", "<leader>tb", ":tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })

-- Typescript tools
vim.keymap.set("n", "<leader>tso", ":TSToolsOrganizeImports<CR>", { desc = "Organize Imports" })
vim.keymap.set("n", "<leader>tss", ":TSToolsSortImports<CR>", { desc = "Sort Imports" })
vim.keymap.set("n", "<leader>tsu", ":TSToolsRemoveUnusedImports<CR>", { desc = "Remove Unused Imports" })
vim.keymap.set("n", "<leader>tsr", ":TSToolsRemoveUnused<CR>", { desc = "Remove Unused Statements" })
vim.keymap.set("n", "<leader>tsa", ":TSToolsAddMissingImports<CR>", { desc = "Add Missing Imports" })
vim.keymap.set("n", "<leader>tsf", ":TSToolsFixAll<CR>", { desc = "Fix All" })
vim.keymap.set("n", "<leader>tsd", ":TSToolsGoToSourceDefinition<CR>", { desc = "Go To Source Definition" })
vim.keymap.set("n", "<leader>tsn", ":TSToolsRenameFile<CR>", { desc = "Rename File" })
vim.keymap.set("n", "<leader>tsF", ":TSToolsFileReferences<CR>", { desc = "File References" })

-- Overseer
-- vim.keymap.set("n", "<leader>or", ":OverseerRun<CR>", { desc = "Overseer run" })

vim.keymap.set("n", "<leader>or", function()
	local overseer = require("overseer")
	overseer.run_template({}, function(task)
		if task then
			overseer.run_action(task, "Open in tasks tab")
		end
	end)
end, { desc = "Overseer toggle" })

vim.keymap.set("n", "<leader>ot", ":OverseerToggle<CR>", { desc = "Overseer toggle" })

-- Toggle dependency versions
vim.keymap.set({ "n" }, "<leader>nt", function()
	require("package-info").toggle({ force = true })
end, { silent = true, noremap = true })

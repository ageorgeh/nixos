return {
	-- nvim-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				on_attach = function(bufnr)
					local copy_file_to_clipboard = require('utils.fs')
					local api = require("nvim-tree.api")

					api.config.mappings.default_on_attach(bufnr)

					vim.keymap.set("n", "<leader>yf", function()
						local node = api.tree.get_node_under_cursor()
						if node then
							copy_file_to_clipboard(node.absolute_path)
						end
					end, {
						buffer = bufnr,
						desc = "Copy file to clipboard",
					})
				end,
				update_cwd = true,
				respect_buf_cwd = true,
				filters = {
					dotfiles = false,
					git_ignored = false,
				},
				view = {
					preserve_window_proportions = true,
				},
				actions = {
					open_file = {
						resize_window = false,
					},
				},
				-- https://github.com/nvim-tree/nvim-tree.lua/blob/master/lua/nvim-tree.lua#L463
				filesystem_watchers = {
					enable = true,
					debounce_delay = 50,
					max_events = 1000,
					ignore_dirs = {
						"/.ccls-cache",
						"/build",
						"/node_modules",
						"/target",
						"/.vite",
						"/.cms",
						"/test-results"
					},
				},
			})
		end,
	},

	-- oil.nvim
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				default_file_explorer = false, -- <-- prevent it from overriding nvim-tree
				view_options = {
					show_hidden = true,
				},
			})
		end,
		keys = {
			{
				"-",
				function()
					require("oil").open()
				end,
				desc = "Open parent directory in Oil",
			},
		},
	},
}

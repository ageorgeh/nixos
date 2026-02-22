return {
	-- nvim-tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				update_cwd = true,
				respect_buf_cwd = true,
				filters = {
					dotfiles = false,
					git_ignored = false,
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
						"/.cms"
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

return {
	"stevearc/overseer.nvim",
	opts = {},
	config = function()
		local overseer = require("overseer")

		-- https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#setup-options
		overseer.setup({
			templates = { "vscode" },
			actions = {},
			task_list = {
				sort = function(a, b)
					-- return require("overseer.task_list").default_sort(a, b)
					-- Sort by name
					return a.name < b.name
				end,
			}
		})
	end,
}

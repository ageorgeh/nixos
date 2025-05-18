local open_tasks_in_task_bar = require("utils.overseer.tasksTab")
return {
	"stevearc/overseer.nvim",
	opts = {},
	config = function()
		local overseer = require("overseer")
		overseer.setup({
			templates = { "vscode" },
			actions = {
				["Open in tasks tab"] = {
					desc = "Open the task in the tasks tab",
					run = function(task)
						open_tasks_in_task_bar(task)
					end,
				},
			},
		})
	end,
}

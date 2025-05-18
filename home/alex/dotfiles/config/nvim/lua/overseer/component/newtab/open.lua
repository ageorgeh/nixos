-- Step 1: Define the custom action

local open_task_in_tasks_tab = require("utils.overseer.tasksTab")

return {
	desc = "Open the task in the tasks tab",
	-- Define parameters that can be passed in to the component
	params = {
		-- See :help overseer-params
	},
	-- Optional, default true. Set to false to disallow editing this component in the task editor
	editable = false,
	-- Optional, default true. When false, don't serialize this component when saving a task to disk
	serializable = true,
	-- The params passed in will match the params defined above
	constructor = function(params)
		-- You may optionally define any of the methods below
		return {
			on_start = function(self, task)
				open_task_in_tasks_tab(task)
			end,
		}
	end,
}

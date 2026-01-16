local function open_task_in_tasks_tab(task)
	local util = require("overseer.util")
	local overseer = require("overseer")

	local tasks_tabnr = nil
	local tab_count = vim.fn.tabpagenr("$")

	-- Check for existing 'Tasks' tab
	for i = 1, tab_count do
		local tabname = vim.t[i].tabname
		if tabname == "Tasks" then
			tasks_tabnr = i
			break
		end
	end

	if tasks_tabnr then
		-- Switch to existing 'Tasks' tab
		vim.cmd("tabnext " .. tasks_tabnr)
	else
		-- Create new 'Tasks' tab and name it
		vim.cmd("tabnew")
		vim.t[vim.fn.tabpagenr()].tabname = "Tasks"
		pcall(vim.cmd, "Tabby rename_tab Tasks")

		-- overseer.open({ enter = false })

		-- Open the task list in the first window
		overseer.open({ enter = false, direction = "bottom" })

		-- Quit the initial window (using the winid opt in open(...) causes it to be tiny)
		vim.cmd(":q")
	end

	vim.cmd("tabprevious " .. (tasks_tabnr or 1))
end
return open_task_in_tasks_tab

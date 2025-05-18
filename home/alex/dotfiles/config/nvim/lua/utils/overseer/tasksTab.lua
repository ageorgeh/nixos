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
		-- Open the task list in the first window
		overseer.open({ enter = false })
	end

	-- Open the task log in a new window within the 'Tasks' tab
	-- Don't like this so much prefer to just use the overseer tasks view
	-- local bufnr = task:get_bufnr()
	-- if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
	-- 	vim.cmd("vsplit")
	-- 	vim.api.nvim_win_set_buf(0, bufnr)
	-- 	util.scroll_to_end(0)
	-- end

	vim.cmd("tabprevious " .. (tasks_tabnr or 1))
end
return open_task_in_tasks_tab

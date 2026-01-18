local function open_task_in_tasks_tab()
	local overseer = require("overseer")

	local cur_tab = vim.api.nvim_get_current_tabpage()

	local function find_tasks_tab()
		for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
			local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "tabname")
			if ok and name == "Tasks" then
				return tab
			end
		end
	end

	local tasks_tab = find_tasks_tab()

	if tasks_tab and vim.api.nvim_tabpage_is_valid(tasks_tab) then
		vim.api.nvim_set_current_tabpage(tasks_tab)
	else
		vim.cmd("tabnew")
		tasks_tab = vim.api.nvim_get_current_tabpage()

		-- Proper tabpage-scoped variable (no numeric indexing)
		vim.api.nvim_tabpage_set_var(tasks_tab, "tabname", "Tasks")
		pcall(vim.cmd, "Tabby rename_tab Tasks")

		overseer.open({ enter = false, direction = "bottom" })

		-- Close the initial window created by :tabnew
		vim.cmd("q")
	end

	-- Return to where you were originally (instead of tabprevious ...)
	if vim.api.nvim_tabpage_is_valid(cur_tab) then
		vim.api.nvim_set_current_tabpage(cur_tab)
	end
end

return open_task_in_tasks_tab

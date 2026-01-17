return {
	"nanozuki/tabby.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local theme = {
			fill = "TabLineFill",
			head = "TabLine",
			current_tab = "TabLineSel",
			tab = "TabLine",
			win = "TabLine",
			tail = "TabLine",
		}

		local function normalize(path)
			return vim.loop.fs_realpath(path)
		end
		require("tabby.tabline").set(function(line)
			local harpoon = require("harpoon"):list()
			local current_buf = vim.api.nvim_get_current_buf()
			local current_file = normalize(vim.api.nvim_buf_get_name(current_buf))

			local tabs = {
				{
					{ "  ", hl = { fg = "#7FBBB3", bg = "#414B50" } },
					line.sep("", theme.head, theme.fill),
				},
				line.tabs().foreach(function(tab)
					local hl = tab.is_current() and theme.current_tab or theme.tab

					-- Get the tab name up til the [
					local name = tab.name()
					local index = string.find(name, "%[%d")
					local tab_name = index and string.sub(name, 1, index - 1) or name

					local modified = false
					local win_ids = require("tabby.module.api").get_tab_wins(tab.id)
					for _, win_id in ipairs(win_ids) do
						if pcall(vim.api.nvim_win_get_buf, win_id) then
							local bufid = vim.api.nvim_win_get_buf(win_id)
							if vim.api.nvim_buf_get_option(bufid, "modified") then
								modified = true
								break
							end
						end
					end

					return {
						line.sep("", hl, theme.fill),
						tab.number(),
						tab_name,
						modified and "",
						tab.close_btn(""),
						line.sep("", hl, theme.fill),
						hl = hl,
						margin = " ",
					}
				end),
				line.spacer(),
				{
					line.sep("", theme.tail, theme.fill),
					{ "  ", hl = theme.tail },
				},
				hl = theme.fill,
			}

			-- Add harpoon items to the end
			-- if harpoon.items then
			-- 	for _, item in ipairs(harpoon.items) do
			-- 		local full_path = normalize(item.value) or item.value
			-- 		local relative_path = vim.fn.fnamemodify(item.value, ":.")
			-- 		local is_active = (full_path == current_file)
			-- 		local hl = is_active and theme.current_tab or theme.tab
			--
			-- 		table.insert(tabs, {
			-- 			line.sep("", hl, theme.fill),
			-- 			relative_path,
			-- 			hl = hl,
			-- 			line.sep("", hl, theme.fill),
			-- 		})
			-- 	end
			-- end

			return tabs
		end)
	end,
}

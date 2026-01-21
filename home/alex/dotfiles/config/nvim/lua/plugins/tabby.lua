return {
	"nanozuki/tabby.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local sel = vim.api.nvim_get_hl(0, { name = "TabLineSel", link = false })
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })

		local theme = {
			fill = "TabLineFill",
			current_tab = {
				fg = sel.fg,
				bg = normal.bg,
			},
			inactive_tab = "TabLine",
			tab = "TabLine",
		}

		local function normalize(path)
			if not path or path == "" then
				return ""
			end
			return vim.loop.fs_realpath(path) or path
		end

		local api = require("tabby.module.api")
		local harpoon = require("harpoon")

		require("tabby.tabline").set(function(line)
			local harpoon_list = harpoon:list()
			local current_buf = vim.api.nvim_get_current_buf()
			local current_file = normalize(vim.api.nvim_buf_get_name(current_buf))

			local segments = {
				{
					{ "  ", hl = theme.current_tab },
					line.sep("", theme.current_tab, theme.fill),
				},

				line.tabs().foreach(function(tab)
					local hl = tab.is_current() and theme.current_tab or theme.tab

					-- Get the tab name up til the [
					local tab_name = tab.name():gsub("%[%d.*$", ""):gsub("%s+$", "")

					local modified = false
					for _, win in ipairs(api.get_tab_wins(tab.id)) do
						if vim.api.nvim_win_is_valid(win) then
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
								modified = true
								break
							end
						end
					end

					local left_dot = tab.is_current() and "●" or "○"

					return {
						line.sep("", tab.is_current() and theme.current_tab or theme.fill, theme.fill),
						" ",
						left_dot,
						" ",
						tab.number(),
						" ",
						"▎",
						tab_name,
						" ",
						modified and "" or " ",
						" ",
						tab.close_btn(""),
						" ",
						line.sep("", tab.is_current() and theme.current_tab or theme.fill, theme.fill),
						hl = hl,
					}
				end),
				line.spacer(),
				hl = theme.fill,
			}

			local keys = { "h", "j", "k", "l" }
			-- Add harpoon items to the end
			if harpoon_list.items then
				for i, item in ipairs(harpoon_list.items) do
					local full_path = normalize(item.value) or item.value
					local relative_path = vim.fn.fnamemodify(item.value, ":.")
					local is_active = (full_path == current_file)
					local hl = is_active and theme.current_tab or theme.tab

					local key = keys[i] or ""

					table.insert(segments, {
						line.sep("", hl, theme.fill),
						" ",
						key,
						" ",
						"▎",
						relative_path,
						" ",
						line.sep("", hl, theme.fill),
						hl = hl,
					})
				end
			end

			table.insert(segments, {
				line.sep("", theme.current_tab, theme.fill),
				{ "  ", hl = theme.current_tab },
			})

			return segments
		end)
	end,
}

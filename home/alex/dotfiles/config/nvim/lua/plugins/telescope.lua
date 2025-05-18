return {
	-- Telescope
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"BurntSushi/ripgrep",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			config = function()
				require("telescope").load_extension("fzf")
			end,
		},
	},
	config = function()
		local telescope_custom_actions = {}
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
			local picker = action_state.get_current_picker(prompt_bufnr)
			local selected_entry = action_state.get_selected_entry()
			local num_selections = #picker:get_multi_selection()
			if not num_selections or num_selections <= 1 then
				actions.add_selection(prompt_bufnr)
			end
			actions.send_selected_to_qflist(prompt_bufnr)
			vim.cmd("cfdo " .. open_cmd)
		end
		function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
			telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
		end
		function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
			telescope_custom_actions._multiopen(prompt_bufnr, "split")
		end
		function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
			telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
		end
		function telescope_custom_actions.multi_selection_open(prompt_bufnr)
			telescope_custom_actions._multiopen(prompt_bufnr, "edit")
		end

		require("telescope").setup({
			defaults = {
				mappings = {
					n = {
						-- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-993956937
						-- ["<CR>"] = telescope_custom_actions.multi_selection_open,
						["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
						["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
						["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
					},
				},
			},
		})
	end,
}

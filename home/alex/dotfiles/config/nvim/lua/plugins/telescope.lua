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
		"nvim-telescope/telescope-ui-select.nvim",
		{
			"nvim-telescope/telescope-live-grep-args.nvim",
		},
	},
	config = function()
		local telescope_custom_actions = {}
		local telescope = require("telescope")
		local action_state = require("telescope.actions.state")
		local actions = require("telescope.actions")
		local lga_actions = require("telescope-live-grep-args.actions")
		local troubleSource = require("trouble.sources.telescope")

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

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-q>"] = function(prompt_bufnr)
							actions.smart_send_to_qflist(prompt_bufnr)
							require("trouble").open({ mode = "qflist" })
						end,
						["<c-t>"] = function(args)
							require("trouble.sources.telescope").open(args)
						end,
						["<C-k>"] = lga_actions.quote_prompt({ postfix = " -U " }),
					},
					n = {
						-- https://github.com/nvim-telescope/telescope.nvim/issues/1048#issuecomment-993956937
						--  = telescope_custom_actions.multi_selection_open,
						["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
						["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
						["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
						["<C-q>"] = function(prompt_bufnr)
							actions.smart_send_to_qflist(prompt_bufnr)
							require("trouble").open({ mode = "qflist" })
						end,
						["<c-t>"] = function()
							troubleSource.open()
						end,
					},
				},
			},
			extensions = {
				["ui-select"] = {},
			},
		})
		telescope.load_extension("live_grep_args")
		telescope.load_extension("ui-select")
	end,
}

return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	---@module "conform"
	---@type conform.setupOpts
	opts = {
		-- Define your formatters
		formatters_by_ft = {
			lua                = { "stylua" },
			python             = { "isort", "black" },
			javascript         = { lsp_format = 'prefer', name = 'oxfmt' },
			typescript         = { lsp_format = 'prefer', name = 'oxfmt' },
			svelte             = { lsp_format = 'prefer', name = 'oxfmt' },
			css                = { lsp_format = 'prefer', name = 'oxfmt' },
			json               = { lsp_format = 'prefer', name = 'oxfmt' },
			jsonc              = { lsp_format = 'prefer', name = 'oxfmt' },
			markdown           = { lsp_format = 'prefer', name = 'oxfmt' },
			yaml               = { lsp_format = 'prefer', name = 'oxfmt' },
			['yaml.ghactions'] = { lsp_format = 'prefer', name = 'oxfmt' },

			-- svelte = function(bufnr)
			-- 	local filename = vim.api.nvim_buf_get_name(bufnr)
			-- 	local function ends_with(str, ending)
			-- 		return ending == "" or str:sub(- #ending) == ending
			-- 	end
			-- 	if ends_with(filename, ".md.svelte") then
			-- 		return { "svx_split_formatter" }
			-- 	else
			-- 		return { lsp_format = "prefer" }
			-- 	end
			-- end,
			svx                = { "svx_split_formatter" },
		},
		-- Set default options
		default_format_opts = {
			lsp_format = "prefer",
		},
		-- Set up format-on-save
		format_on_save = { timeout_ms = 500, lsp_format = "prefer", },
		-- Customize formatters
		formatters = {
			shfmt = {
				prepend_args = { "-i", "2" },
			},
			svx_split_formatter = {
				command = "bun",
				args = { vim.fn.stdpath("config") .. "/scripts/format_md_svelte.ts", "$FILENAME" },
				stdin = true,
			},
		},
	},
	init = function()
		-- If you want the formatexpr, here is the place to set it
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}

return {
	-- "rose-pine/neovim",
	-- lazy = false,
	-- priority = 1000,
	-- name = "rose-pine",
	-- config = function()
	--     require("rose-pine").setup({
	--         dim_inactive_windows = true,
	--         styles = {
	--             transparency = true
	--         },
	--     })
	--     vim.cmd("colorscheme rose-pine")
	--     -- vim.api.nvim_set_hl(0, "NormalNC", {
	--     --     bg = "NONE",
	--     --     fg = "#6e6a86",
	--     -- })
	-- end

	-- "catppuccin/nvim",
	-- name = "catppuccin",
	-- priority = 1000,
	-- config = function()
	--     -- https://github.com/catppuccin/nvim#configuration
	--     vim.cmd("colorscheme catppuccin")
	-- end

	"ellisonleao/gruvbox.nvim",
	name = "gruvbox",
	priority = 1000,
	config = function()
		-- https://github.com/ellisonleao/gruvbox.nvim#configuration
		require("gruvbox").setup({
			contrast = "hard",
		})
		vim.o.background = "dark"
		vim.cmd("colorscheme gruvbox")
	end,
}

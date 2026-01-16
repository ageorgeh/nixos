return {
	-- LSP and completion
	"neovim/nvim-lspconfig",
	-- "hrsh7th/nvim-cmp",
	-- "hrsh7th/cmp-nvim-lsp",
	-- "L3MON4D3/LuaSnip",
	"mbbill/undotree",
	"b0o/schemastore.nvim",
	{
		dir = vim.fn.stdpath("config") .. "/local/termui",
		dependencies = { "nvim-lua/plenary.nvim" },
		name = "termui",
		lazy = false,
	},
}

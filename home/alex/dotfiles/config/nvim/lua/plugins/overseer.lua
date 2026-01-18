return {
	"stevearc/overseer.nvim",
	opts = {},
	config = function()
		local overseer = require("overseer")
		overseer.setup({
			templates = { "vscode" },
			actions = {},
		})
	end,
}

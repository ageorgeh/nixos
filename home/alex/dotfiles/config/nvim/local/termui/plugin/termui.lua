vim.api.nvim_create_user_command("TermUI", function()
	require("termui").open()
end, {})

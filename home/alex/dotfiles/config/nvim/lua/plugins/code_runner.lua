-- https://github.com/CRAG666/code_runner.nvim
return {
    "CRAG666/code_runner.nvim",
    config = function()
        require('code_runner').setup({
            term = {
                position = "right"
            },
            focus = false,
            filetype = {
                -- typescript = "echo ehllo"
            }
        })
    end
}

-- https://github.com/Sebastian-Nielsen/better-type-hover
return {
    "Sebastian-Nielsen/better-type-hover",
    ft = { "typescript", "typescriptreact" },
    config = function()
        require("better-type-hover").setup({
            openTypeDocKeymap = "<C-O>",
        })
    end,
}

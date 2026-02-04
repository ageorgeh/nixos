vim.filetype.add({
    pattern = {
        [".*/.vscode/.*%.json"] = "jsonc",
    },
})

-- https://github.com/actions/languageservices/tree/main/languageserver#in-neovim
vim.filetype.add({
    pattern = {
        [".*/%.github/workflows/.*%.ya?ml"] = "yaml.ghactions",
    },
})

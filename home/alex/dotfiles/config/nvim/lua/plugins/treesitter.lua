return -- Treesitter
{
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- force main branch
    build = ":TSUpdate",
    lazy = false,
    config = function()
        local parsers = {
            'c',
            'cpp',
            'make',
            'dockerfile',
            'bash',
            'markdown',
            'git_config',
            'git_rebase',
            'gitattributes',
            'gitcommit',
            'gitignore',
            "html",
            "html_tags",
            'json',
            'lua',
            'python',
            "lua", "rust", "python", "javascript", "typescript", "markdown", "go", "svelte", "typst"
        }
        require('nvim-treesitter').install(parsers)


        -- https://github.com/nvim-treesitter/nvim-treesitter/discussions/8546
        local function is_parser_installed(lang)
            local installed = require("nvim-treesitter").get_installed()
            return vim.tbl_contains(installed, lang)
        end

        local function is_parser_available(lang)
            local available = require("nvim-treesitter").get_available()
            return vim.tbl_contains(available, lang)
        end

        local function start_treesitter(buf, lang)
            if not vim.treesitter.language.add(lang) then
                vim.notify(
                    "Cannot load treesitter parser for language " .. lang,
                    vim.log.levels.WARN
                )
                return
            end
            vim.treesitter.start(buf)
            vim.bo[buf].syntax = "ON"
            if vim.treesitter.query.get(lang, "indents") then
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                local lang = vim.treesitter.language.get_lang(ev.match)
                if not lang then
                    return
                end
                local buf = ev.buf
                if is_parser_installed(lang) then
                    start_treesitter(buf, lang)
                elseif is_parser_available(lang) then
                    require("nvim-treesitter").install({ lang }):await(function()
                        start_treesitter(buf, lang)
                    end)
                end
            end,
        })


        vim.api.nvim_create_autocmd("User", {
            pattern = "TSUpdate",
            callback = function()
                require("nvim-treesitter.parsers").svelte = {
                    install_info = {
                        url = "https://github.com/ageorgeh/tree-sitter-svelte",
                        revision = "master",
                        queries = "queries",
                    },
                }
            end,
        })
    end,
}

-- Starting point for new LSP https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/configs
local util = require("lspconfig.util")
local vs = require("utils.vscode.settings")

vim.lsp.enable("lua_ls")

vim.lsp.config("svelte", {
	filetypes = { "svelte", "svx" },
	on_attach = function(client, bufnr)
		if client.name == "svelte" then
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.js", "*.ts" },
				callback = function(ctx)
					client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
				end,
			})
		end
	end,
})
vim.lsp.enable("svelte")

-- vim.lsp.config("ts_ls", require("lsp.ts_ls"))
-- vim.lsp.enable("ts_ls")

vim.lsp.enable("typescript-tools")

vim.lsp.config("tailwindcss", {
	settings = {
		tailwindCSS = {
			validate = true,
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidScreen = "error",
				invalidVariant = "error",
				invalidConfigPath = "error",
				invalidTailwindDirective = "error",
				recommendedVariantOrder = "warning",
			},
			classAttributes = {
				"class",
				"className",
				"class:list",
				"classList",
				"ngClass",
				"imgClass",
			},
			includeLanguages = {
				eelixir = "html-eex",
				eruby = "erb",
				templ = "html",
				htmlangular = "html",
			},
			experimental = {
				configFile = vs.get(vs.load(), "tailwindCSS.experimental.configFile"),
			},
		},
	},
	root_dir = function(bufnr, on_dir)
		local root_files = {
			"pnpm-lock.yaml",
			-- Generic
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.mjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.cjs",
			"postcss.config.mjs",
			"postcss.config.ts",
			-- Django
			"theme/static_src/tailwind.config.js",
			"theme/static_src/tailwind.config.cjs",
			"theme/static_src/tailwind.config.mjs",
			"theme/static_src/tailwind.config.ts",
			"theme/static_src/postcss.config.js",
		}
		local fname = vim.api.nvim_buf_get_name(bufnr)
		-- root_files = util.insert_package_json(root_files, "tailwindcss", fname)
		-- root_files = util.root_markers_with_field(root_files, { "mix.lock", "Gemfile.lock" }, "tailwind", fname)
		on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
	end,
})
vim.lsp.enable("tailwindcss")
vim.lsp.enable("nixd")
vim.lsp.config('nixd', {
	cmd = { 'nixd' },
	filetypes = { 'nix' },
	root_markers = { 'flake.nix', '.git' },
	settings = {
		nixd = {
			formatting = {
				command = { "nixfmt" },
			},
		},
	},
})

-- vim.lsp.config("jsonls", {
-- 	cmd = { "vscode-json-languageserver", "--stdio" },
-- })
vim.lsp.enable("jsonls")
vim.lsp.enable("bashls")
vim.lsp.enable("glsl_analyzer")
vim.lsp.enable("gopls")

-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
--
-- 		if client:supports_method("textDocument/completion") then
-- 			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })

-- vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
-- vim.opt.shortmess:append("c")

local function tab_complete()
	if vim.fn.pumvisible() == 1 then
		-- navigate to next item in completion menu
		return "<Down>"
	end

	local c = vim.fn.col(".") - 1
	local is_whitespace = c == 0 or vim.fn.getline("."):sub(c, c):match("%s")

	if is_whitespace then
		-- insert tab
		return "<Tab>"
	end

	local lsp_completion = vim.bo.omnifunc == "v:lua.vim.lsp.omnifunc"

	if lsp_completion then
		-- trigger lsp code completion
		return "<C-x><C-o>"
	end

	-- suggest words in current buffer
	return "<C-x><C-n>"
end

local function tab_prev()
	if vim.fn.pumvisible() == 1 then
		-- navigate to previous item in completion menu
		return "<Up>"
	end

	-- insert tab
	return "<Tab>"
end

-- vim.keymap.set("i", "<Tab>", tab_complete, { expr = true })
-- vim.keymap.set("i", "<S-Tab>", tab_prev, { expr = true })

-- Using conform now
-- Formatting on save
-- vim.api.nvim_create_autocmd('LspAttach', {
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--
--         if client:supports_method('textDocument/formatting') then
--             vim.api.nvim_create_autocmd('BufWritePre', {
--                 buffer = args.buf,
--                 callback = function()
--                     vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
--                 end,
--             })
--         end
--     end,
-- })

-- Inlay hints
-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(args)
-- 		local client = vim.lsp.get_client_by_id(args.data.client_id)
--
-- 		if client:supports_method("textDocument/inlayHint") then
-- 			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
-- 		end
-- 	end,
-- })

-- Highlight references
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if client and client:supports_method("textDocument/documentHighlight") then
			local autocmd = vim.api.nvim_create_autocmd
			local augroup = vim.api.nvim_create_augroup("lsp_highlight", { clear = false })

			vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })

			autocmd({ "CursorHold" }, {
				group = augroup,
				buffer = args.buf,
				callback = vim.lsp.buf.document_highlight,
			})

			autocmd({ "CursorMoved" }, {
				group = augroup,
				buffer = args.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})

-- -- Show diagnostics (errors etc) on hold for a line
vim.api.nvim_create_autocmd("CursorHold", {
	pattern = "*",
	callback = function()
		-- Length of diagnostics for current buffer == 0
		if #vim.diagnostic.get(0) == 0 then
			return
		end

		if not vim.b.diagnostics_pos then
			vim.b.diagnostics_pos = { nil, nil }
		end

		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		if cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2] then
			vim.diagnostic.open_float()
		end

		vim.b.diagnostics_pos = cursor_pos
	end,
})

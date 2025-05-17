local util = require("lsp.util")
local tailwindls_path = vim.fn.exepath("tailwindcss-language-server")
return {
	cmd = {
		"node",
		"--max-old-space-size=4096",
		tailwindls_path,
		"--stdio",
	},
	-- filetypes copied and adjusted from tailwindcss-intellisense
	filetypes = {
		-- html
		"aspnetcorerazor",
		"astro",
		"astro-markdown",
		"blade",
		"clojure",
		"django-html",
		"htmldjango",
		"edge",
		"eelixir", -- vim ft
		"elixir",
		"ejs",
		"erb",
		"eruby", -- vim ft
		"gohtml",
		"gohtmltmpl",
		"haml",
		"handlebars",
		"hbs",
		"html",
		"htmlangular",
		"html-eex",
		"heex",
		"jade",
		"leaf",
		"liquid",
		"markdown",
		"mdx",
		"mustache",
		"njk",
		"nunjucks",
		"php",
		"razor",
		"slim",
		"twig",
		-- css
		"css",
		"less",
		"postcss",
		"sass",
		"scss",
		"stylus",
		"sugarss",
		-- js
		"javascript",
		"javascriptreact",
		"reason",
		"rescript",
		"typescript",
		"typescriptreact",
		-- mixed
		"vue",
		"svelte",
		"templ",
	},
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
			},
			includeLanguages = {
				eelixir = "html-eex",
				eruby = "erb",
				templ = "html",
				htmlangular = "html",
			},
			files = {
				exclude = {
					"**/.git/**",
					"**/node_modules/**",
					"**/.hg/**",
					"**/.svn/**",
				},
			},
			experimental = {
				configFile = "src/app.css",
			},
		},
	},
	on_new_config = function(new_config)
		if not new_config.settings then
			new_config.settings = {}
		end
		if not new_config.settings.editor then
			new_config.settings.editor = {}
		end
		if not new_config.settings.editor.tabSize then
			-- set tab size for hover
			new_config.settings.editor.tabSize = vim.lsp.util.get_effective_tabstop()
		end
	end,
	root_dir = function(fname, on_dir)
		local root_file = {
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.mjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.cjs",
			"postcss.config.mjs",
			"postcss.config.ts",
		}
		root_file = util.insert_package_json(root_file, "tailwindcss", fname) -- Log what files we're looking for and the filename vim.notify(
		-- 	"Tailwind root_dir: Searching for root in " .. fname .. " with patterns: " .. vim.inspect(root_file),
		-- 	vim.log.levels.INFO
		-- )

		local root = util.root_pattern(unpack(root_file))(fname)

		-- Log the result
		vim.notify("Tailwind root_dir: resolved root = " .. tostring(root), vim.log.levels.INFO)

		on_dir(root)
	end,
	docs = {
		description = [[
https://github.com/tailwindlabs/tailwindcss-intellisense

Tailwind CSS Language Server can be installed via npm:
```sh
npm install -g @tailwindcss/language-server
```
]],
	},
}

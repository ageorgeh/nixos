-- lua/vscode_settings.lua
local M = {}

-- Remove //… and /*…*/ comments plus trailing commas in objects/arrays
local function strip_jsonc(s)
	-- strip single‑line comments
	s = s:gsub("//[^\n]*", "")
	-- strip block comments
	s = s:gsub("/%*.-%*/", "")
	-- strip trailing commas before } or ]
	s = s:gsub(",%s*}", "}")
	s = s:gsub(",%s*]", "]")
	return s
end

-- Load and parse .vscode/settings.json (supports JSONC)
function M.load(cwd)
	cwd = cwd or vim.fn.getcwd()
	local path = cwd .. "/.vscode/settings.json"
	if vim.fn.filereadable(path) == 0 then
		return nil
	end

	local lines = vim.fn.readfile(path)
	local raw = table.concat(lines, "\n"):gsub("\r\n", "\n") -- normalize line endings
	local cleaned = strip_jsonc(raw)

	local ok, decoded = pcall(vim.fn.json_decode, cleaned)
	if not ok then
		vim.notify("Failed parsing JSONC at " .. path, vim.log.levels.ERROR)
		return nil
	end

	return decoded
end

-- Get a setting by dot‑path, supporting flat keys or nested tables
function M.get(settings, key)
	if type(settings) ~= "table" or type(key) ~= "string" then
		return nil
	end

	-- flat key first
	if settings[key] ~= nil then
		return settings[key]
	end

	-- nested lookup
	local parts = vim.split(key, "%.")
	local cur = settings
	for _, part in ipairs(parts) do
		if type(cur) == "table" and cur[part] ~= nil then
			cur = cur[part]
		else
			return nil
		end
	end

	return cur
end

return M

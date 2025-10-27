-- lua/vscode_settings.lua
local M = {}

-- Remove //… and /*…*/ comments plus trailing commas in objects/arrays
local function strip_jsonc(s)
	-- pass 1: remove comments, preserving strings
	local out, i, n = {}, 1, #s
	local in_str, quote, esc = false, nil, false
	local line_c, block_c = false, false

	while i <= n do
		local c = s:sub(i, i)
		local d = s:sub(i + 1, i + 1)

		if block_c then
			if c == "*" and d == "/" then
				block_c = false; i = i + 2
			else
				i = i + 1
			end
		elseif line_c then
			if c == "\n" then
				line_c = false; out[#out + 1] = c
			end
			i = i + 1
		elseif in_str then
			out[#out + 1] = c
			if esc then
				esc = false
			elseif c == "\\" then
				esc = true
			elseif c == quote then
				in_str = false
			end
			i = i + 1
		else
			if c == "/" and d == "/" then
				line_c = true; i = i + 2
			elseif c == "/" and d == "*" then
				block_c = true; i = i + 2
			else
				out[#out + 1] = c
				if c == '"' or c == "'" then
					in_str = true; quote = c
				end
				i = i + 1
			end
		end
	end

	local s2 = table.concat(out)

	-- pass 2: drop trailing commas outside strings
	out, i, n = {}, 1, #s2
	in_str, quote, esc = false, nil, false

	while i <= n do
		local c = s2:sub(i, i)
		if in_str then
			out[#out + 1] = c
			if esc then
				esc = false
			elseif c == "\\" then
				esc = true
			elseif c == quote then
				in_str = false
			end
			i = i + 1
		else
			if c == '"' or c == "'" then
				in_str = true; quote = c; out[#out + 1] = c; i = i + 1
			elseif c == "," then
				local j = i + 1
				while j <= n and s2:sub(j, j):match("%s") do j = j + 1 end
				local nxt = s2:sub(j, j)
				if nxt == "}" or nxt == "]" then
					i = i + 1 -- skip comma
				else
					out[#out + 1] = c; i = i + 1
				end
			else
				out[#out + 1] = c; i = i + 1
			end
		end
	end

	return table.concat(out)
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
		print(raw)
		print(cleaned)
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

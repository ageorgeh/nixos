local function copy_file_to_clipboard(path)
    if not path or path == "" then
        vim.notify("No file to copy", vim.log.levels.WARN)
        return
    end

    if vim.fn.isdirectory(path) == 1 then
        vim.notify("Cannot copy directory contents: " .. path, vim.log.levels.WARN)
        return
    end

    if vim.fn.filereadable(path) ~= 1 then
        vim.notify("File not readable: " .. path, vim.log.levels.ERROR)
        return
    end

    local mime = vim.fn.system({ "file", "--mime-type", "-b", path }):gsub("%s+$", "")

    local cmd
    if mime:match("^image/") then
        cmd = { "sh", "-c", 'wl-copy --type "$1" < "$2"', "sh", mime, path }
    else
        cmd = { "sh", "-c", 'wl-copy < "$1"', "sh", path }
    end

    vim.system(cmd, {}, function(result)
        vim.schedule(function()
            if result.code == 0 then
                vim.notify("Copied file to clipboard: " .. vim.fn.fnamemodify(path, ":t"))
            else
                vim.notify("wl-copy failed", vim.log.levels.ERROR)
            end
        end)
    end)
end

return copy_file_to_clipboard

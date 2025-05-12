return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon.setup()
        vim.o.showtabline = 2 -- always show tabline

        vim.o.tabline = "%!v:lua.HarpoonTabline()"

        function _G.HarpoonTabline()
            local tabline = ""
            if harpoon.items then
                for i, item in ipairs(harpoon.items) do
                    local filename = vim.fn.fnamemodify(item.value, ":t")
                    tabline = tabline .. "%" .. i .. "T " .. filename .. " "
                end
            end

            return tabline
        end
    end
}

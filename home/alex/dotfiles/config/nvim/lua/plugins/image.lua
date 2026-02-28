return {
    "3rd/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = false,
    opts = {
        backend = "kitty",
        processor = "magick_cli",
    },
}

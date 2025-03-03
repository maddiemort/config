require'noice'.setup {
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    cmdline = {
        view = "cmdline",
    },
    presets = {
        bottom_search = true,
        command_palette = true,
    },
    notify = { enabled = true },
    routes = {
        {
            filter = {
                error = true,
                find = "Invalid offset LineCol",
            },
            opts = { skip = true },
        },
    }
}

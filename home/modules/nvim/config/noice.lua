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
        format = {
            cmdline = { pattern = "^:", conceal = false, icon = false, lang = "vim" },
            search_down = { kind = "search", pattern = "^/", conceal = false, icon = false, lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", conceal = false, icon = false, lang = "regex" },
            filter = { pattern = "^:%s*!", conceal = false, icon = false, lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, conceal = false, icon = false, lang = "lua" },
            help = false,
            input = false,
        },
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

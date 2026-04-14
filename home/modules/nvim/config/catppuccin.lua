require'catppuccin'.setup {
    flavour = 'macchiato',
    dim_inactive = {
        enabled = true,
        percentage = 0.50,
    },
    no_italic = true,
    no_bold = true,
    no_underline = true,
    custom_highlights = function(colors)
        return {
            Comment = { fg = colors.overlay2, style = { }, },
            SpecialComment = { fg = colors.overlay2, style = { "italic" }, },
            Special = { fg = colors.pink, style = { "italic" } },
        }
    end,
    integrations = {
        cmp = true,
        fidget = true,
        fzf = true,
        indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
        },
        lualine = {
            enabled = true,
        },
        illuminate = {
            -- I don't like the way catppuccin sets a background colour for the illuminated words
            enabled = false,
        },
        notify = true,
        signify = true,
        snacks = true,
        telescope = true,
    },
}

vim.cmd.colorscheme 'catppuccin-nvim'

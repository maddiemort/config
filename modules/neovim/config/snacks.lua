require'snacks'.setup {
    styles = {
        input = {
            relative = "cursor",
            row = -3,
        },
    },
    input = {
        enabled = true,
        icon = "",
    },
    notifier = {
        enabled = true,
        icons = {
            error = "●", -- U+25CF BLACK CIRCLE
            warn = "◎", -- U+25CE BULLSEYE
            info = "◍", -- U+25CD CIRCLE WITH VERTICAL FILL
            debug = "○", -- U+25CB WHITE CIRCLE
            trace = "◌", -- U+25CC DOTTED CIRCLE
        },
    },
}

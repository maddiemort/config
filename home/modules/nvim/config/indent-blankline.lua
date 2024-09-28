local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowPeach",
    "RainbowGreen",
    "RainbowMauve",
    "RainbowTeal",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#ed8796" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#eed49f" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#8aadf4" })
    vim.api.nvim_set_hl(0, "RainbowPeach", { fg = "#f5a97f" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#a6da95" })
    vim.api.nvim_set_hl(0, "RainbowMauve", { fg = "#c6a0f6" })
    vim.api.nvim_set_hl(0, "RainbowTeal", { fg = "#8bd5ca" })

    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#ed8796" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#eed49f" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#8aadf4" })
    vim.api.nvim_set_hl(0, "RainbowPeach", { fg = "#f5a97f" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#a6da95" })
    vim.api.nvim_set_hl(0, "RainbowMauve", { fg = "#c6a0f6" })
    vim.api.nvim_set_hl(0, "RainbowTeal", { fg = "#8bd5ca" })
end)

require'ibl'.setup {
    scope = {
        enabled = false,
    },
    indent = {
        char = '│',
        -- Left aligned:
        -- char = '▏',
        highlight = highlight,
    },
}

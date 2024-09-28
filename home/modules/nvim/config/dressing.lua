require'dressing'.setup{
    select = {
        telescope = require'telescope.themes'.get_cursor { }
    },
}

local colors_group = vim.api.nvim_create_augroup('dressing-colors', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = colors_group,
    pattern = '*',
    callback = function()
        -- This colour is "Surface 0" from Catppuccin Macchiato.
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#363a4f" })
    end,
})

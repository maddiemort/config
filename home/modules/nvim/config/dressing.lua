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
        vim.cmd('highlight FloatTitle guifg=#abb2bf guibg=NONE')
        vim.cmd('highlight FloatBorder guifg=#abb2bf guibg=#3e4452')
    end,
})

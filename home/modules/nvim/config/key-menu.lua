local keymenu = require'key-menu'

keymenu.set('n', '<leader>')
keymenu.set('n', 'g')
keymenu.set('n', 'gh', { desc = 'Git' })

local colors_group = vim.api.nvim_create_augroup('keymenu-colors', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = colors_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight KeyMenuNormal guifg=#abb2bf guibg=NONE')
        vim.cmd('highlight KeyMenuFloatBorder guifg=#abb2bf guibg=NONE')
    end,
})

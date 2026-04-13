-- Use a bar for all the different status signs in the buffer, so that they're all just
-- distinguished by colour and not character
vim.g.signify_sign_add = '▏'
vim.g.signify_sign_change = '▏'
vim.g.signify_sign_change_delete = '▏'
vim.g.signify_sign_delete = '▏'
vim.g.signify_sign_delete_first_line = '▏'

vim.g.signify_skip = {
    vcs = {
        allow = {
            'jj',
            -- 'git',
        },
    },
}

vim.g.signify_vcs_cmds_diffmode = {
    git = "git show HEAD:./%f",
    jj = "jj file show -r 'first_parent(@)' -- %f || true",
}

-- Remove the background from all the diff highlight groups, and use it as the foreground instead
local colors_group = vim.api.nvim_create_augroup('signify-colors', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = colors_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight! DiffAdd guifg=#a6da95 guibg=NONE')
        vim.cmd('highlight! DiffChange guifg=#eed49f guibg=NONE')
        vim.cmd('highlight! DiffDelete guifg=#ed8796 guibg=NONE')
        vim.cmd('highlight! DiffText guifg=#8aadf4 guibg=NONE')
    end,
})

-- This might reduce performance (especially as the result of interactions with plugins/LSP), so be
-- careful
vim.cmd('set updatetime=100')

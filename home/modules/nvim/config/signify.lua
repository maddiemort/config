-- Use a bar for all the different status signs in the buffer, so that they're all just
-- distinguished by colour and not character
vim.g.signify_sign_add = '▏'
vim.g.signify_sign_change = '▏'
vim.g.signify_sign_change_delete = '▏'
vim.g.signify_sign_delete = '▏'
vim.g.signify_sign_delete_first_line = '▏'
vim.g.signify_show_count = false

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

-- This might reduce performance (especially as the result of interactions with plugins/LSP), so be
-- careful
vim.cmd('set updatetime=100')

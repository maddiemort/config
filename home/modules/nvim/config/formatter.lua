local formatter = require'formatter'
local util = require'formatter.util'

formatter.setup {
    logging = true,
    log_level = vim.log.levels.WARN,
    filetype = {
        c = {
            require'formatter.filetypes.c'.clangformat,
        },
        cpp = {
            require'formatter.filetypes.cpp'.clangformat,
        },
        rust = {
            require'formatter.filetypes.rust'.rustfmt,
        },
    },
}

local formatter_group = vim.api.nvim_create_augroup('formatter', {})
vim.api.nvim_create_autocmd('BufWritePost', {
    group = formatter_group,
    pattern = '*',
    callback = function()
        vim.cmd('FormatWriteLock')
    end,
})

local formatter = require'formatter'

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
            function()
                return {
                    exe = "rustfmt",
                    args = { },
                    stdin = true,
                }
            end,
        },
        typst = {
            function()
                return {
                    exe = "typstfmt",
                }
            end,
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

local id = vim.api.nvim_create_augroup('commentstring-fix', {})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    group = id,
    callback = function()
        if vim.bo.commentstring == '//%s' then
            vim.bo.commentstring = '// %s'
        end
    end,
})


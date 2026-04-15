vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('enable-treesitter-rust', {}),
    pattern = 'rust',
    callback = function()
        vim.treesitter.start()
    end,
})

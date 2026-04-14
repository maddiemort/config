require("nvim-treesitter.configs").setup {
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('enable-treesitter-rust', {}),
    pattern = 'rust',
    callback = function()
        vim.treesitter.start()
    end,
})

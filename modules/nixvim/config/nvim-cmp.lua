local cmp = require'cmp'
local luasnip = require'luasnip'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Run the plugin setup function
cmp.setup {
    snippet = {
        expand = function(args)
            -- luasnip.lsp_expand(args.body)
            vim.snippet.expand(args.body)
        end,
    },
    mapping = {
        ['<Tab>'] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end,
            c = function()
                if cmp.visible() then
                    cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    cmp.complete()
                end
            end,
        }),
        ['<S-Tab>'] = cmp.mapping({
            i = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
                else
                    vim.cmd(':<')
                end
            end,
            c = function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
                else
                    fallback()
                end
            end,
        }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<CR>'] = cmp.mapping(cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }), { 'i', 's' }),
    },
    completion = {
        autocomplete = false,
    },
    sources = {
        { name = 'nvim_lsp' },
    },
    experimental = {
        ghost_text = true,
    },
    formatting = {
        format = require'lspkind'.cmp_format {
            mode = 'symbol',
            maxwidth = 50,
        },
    },
}

cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'fuzzy_path' }
    }, {
        { name = 'cmdline' }
    })
})

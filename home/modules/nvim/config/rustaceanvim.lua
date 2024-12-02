local cmp_lsp = require'cmp_nvim_lsp'
local capabilities = cmp_lsp.default_capabilities()

local inlay_group = vim.api.nvim_create_augroup('inlay_highlight', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = inlay_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight! LspInlayHint ctermfg=59 guifg=#5c6370 gui=italic')
    end,
})

vim.g.rustaceanvim = {
    tools = {
    },
    server = {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
        default_settings = {
            ['rust-analyzer'] = {
                assist = {
                    importEnforceGranularity = true,
                    importPrefix = "crate",
                },
                -- cargo = {
                --     allFeatures = true,
                -- },
                -- checkOnSave = {
                --     command = "clippy",
                -- },
                completion = {
                    postfix = {
                        enable = false,
                    },
                },
                diagnostics = {
                    disabled = {
                        "unresolved-proc-macro",
                    },
                },
                hover = {
                    links = {
                        -- It's ugly when rust-analyzer tries to display docs.rs
                        -- links for links in markdown docs.
                        enable = false,
                    },
                    imports = {
                        prefix = {
                            "self",
                        },
                    },
                },
            },
        },
    },
    dap = {
    },
}

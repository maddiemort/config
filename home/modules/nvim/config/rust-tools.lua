local cmp_lsp = require'cmp_nvim_lsp'
local capabilities = cmp_lsp.default_capabilities()

local inlay_group = vim.api.nvim_create_augroup('inlay_highlight', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = inlay_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight RustToolsInlayHint ctermfg=59 guifg=#5c6370 gui=italic')
    end,
})

-- Run the plugin setup function
require('rust-tools').setup({
    tools = {
        inlay_hints = {
            parameter_hints_prefix = "› ",
            other_hints_prefix = "» ",
            highlight = "RustToolsInlayHint",
        }
    },

    server = {
        capabilities = capabilities,
        settings = {
            flags = {
                debounce_text_changes = 150,
            },
            ["rust-analyzer"] = {
                assist = {
                    importEnforceGranularity = true,
                    importPrefix = "crate",
                },
                checkOnSave = {
                    -- command = "clippy",
                },
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
})

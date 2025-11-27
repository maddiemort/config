local signs = {
    [vim.diagnostic.severity.ERROR] = "●", -- U+25CF BLACK CIRCLE
    [vim.diagnostic.severity.WARN] = "◎", -- U+25CE BULLSEYE
    [vim.diagnostic.severity.INFO] = "○", -- U+25CB WHITE CIRCLE
    [vim.diagnostic.severity.HINT] = "◌", -- U+25CC DOTTED CIRCLE
}

-- local signs = {
--     [vim.diagnostic.severity.ERROR] = "☣",
--     [vim.diagnostic.severity.WARN] = "☢",
--     [vim.diagnostic.severity.INFO] = "❄",
--     [vim.diagnostic.severity.HINT] = "⚙",
-- }

vim.diagnostic.config {
    severity_sort = true,
    signs = {
        text = signs,
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
    virtual_text = {
        severity = {
            min = vim.diagnostic.severity.HINT,
        },
        format = function(diagnostic)
            -- Only show the first line of each diagnostic in virtual text
            return string.gmatch(diagnostic.message, "[^\n]+")()
        end,
        source = "if_many",
        spacing = 0,

        -- prefix = function(diagnostic, i, total)
        --     -- Print a single symbol no matter how many diagnostics there are
        --     if i == total then
        --         return '⚕'
        --     end
        -- end,

        prefix = function(diagnostic, i, total)
            -- Print a single symbol representing the severity of the most severe diagnostic
            if i == total then
                return signs[diagnostic.severity]
            else
                return ""
            end
        end,
    },
}

-- parameter hints: "› "
-- other hints: "» "
-- I don't think anything is actually using this anymore
vim.fn.sign_define("LspInlayHint", { text = "» ", texthl = "LspInlayHint", numhl = "LspInlayHint" })

vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
    local lvl = ({
        vim.log.levels.ERROR,
        vim.log.levels.WARN,
        vim.log.levels.INFO,
        vim.log.levels.DEBUG,
    })[result.type]

    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local title
    if client ~= nil then
        title = 'LSP | ' .. client.name
    else
        title = 'LSP'
    end

    vim.notify(result.message, lvl, {
        title = title,
    })
end

-- vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
--     config = config or {}
--     config.focus_id = ctx.method
--     if not (result and result.contents) then
--         notify('No information available', 'ERROR')
--         return
--     end
--     local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
--     markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
--     if vim.tbl_isempty(markdown_lines) then
--         notify('No information available', 'WARN')
--         return
--     end
--     return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
-- end

local undercurl_group = vim.api.nvim_create_augroup('lsp_undercurl', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = undercurl_group,
    pattern = '*',
    callback = function()
        vim.cmd('highlight DiagnosticUnderlineHint gui=undercurl')
        vim.cmd('highlight DiagnosticUnderlineInfo gui=undercurl')
        vim.cmd('highlight DiagnosticUnderlineWarn gui=undercurl')
        vim.cmd('highlight DiagnosticUnderlineError gui=undercurl')
    end,
})

-- Code navigation shortcuts
vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, { desc = 'Documentation' })
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { desc = 'Rename' })
vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { desc = 'Code Actions' })

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        vim.keymap.del('n', 'K', { buffer = ev.buf })
    end,
})

-- Map shortcuts for telescope LSP pickers
vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', { desc = 'Goto Definition' })
vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', { desc = 'Goto Implementations' })
vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', { desc = 'Goto References' })
vim.keymap.set('n', 'gy', '<cmd>Telescope lsp_type_definitions<cr>', { desc = 'Goto Type Definition' })
vim.keymap.set('n', '<leader>d', '<cmd>Telescope diagnostics bufnr=0<cr>', { desc = 'Document Diagnostics' })
vim.keymap.set('n', '<leader>e', '<cmd>Telescope diagnostics bufnr=0 severity_limit=1<cr>', { desc = 'Document Errors' })
vim.keymap.set('n', '<leader>w', '<cmd>Telescope diagnostics bufnr=0 severity_limit=2<cr>', { desc = 'Document Warnings/Errors' })
vim.keymap.set('n', '<leader>D', '<cmd>Telescope diagnostics<cr>', { desc = 'Workspace Diagnostics' })
vim.keymap.set('n', '<leader>E', '<cmd>Telescope diagnostics severity_limit=1<cr>', { desc = 'Document Errors' })
vim.keymap.set('n', '<leader>W', '<cmd>Telescope diagnostics severity_limit=2<cr>', { desc = 'Document Warnings/Errors' })
vim.keymap.set('n', '<leader>y', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'Document Symbols' })
vim.keymap.set('n', '<leader>Y', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = 'Workspace Symbols' })

vim.lsp.config("*", {
    root_markers = { ".git", ".jj", },
})

local _ran_once = {}
vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            assist = {
                preferSelf = true,
            },
            cargo = {
                -- allFeatures = true,
                extraArgs = {
                    "--profile",
                    "rust-analyzer",
                },
                extraEnv = {
                    ["CARGO_PROFILE_RUST_ANALYZER_INHERITS"] = "dev",
                },
            },
            check = {
                command = "clippy",
                -- extraArgs = {
                --     "--profile",
                --     "rust-analyzer",
                -- },
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
            gotoImplementations = {
                filterAdjacentDerives = true,
            },
            hover = {
                links = {
                    -- It's ugly when rust-analyzer tries to display docs.rs links for links in
                    -- markdown docs.
                    enable = false,
                },
            },
            imports = {
                granularity = {
                    -- Not sure what I want this set to yet
                    enforce = false,
                },
            },
            inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = {
                    enable = true,
                    minLines = 25,
                },
                closureCaptureHints = { enable = true },
                closureReturnTypeHints = { enable = "never" },
                closureStyle = "impl_fn",
                discriminantHints = { enable = "never" },
                expressionAdjustmentHints = {
                    disableReborrows = true,
                    enable = "always",
                    hideOutsideUnsafe = true,
                    mode = "prefix",
                },
                genericParameterHints = {
                    const = { enable = true },
                    lifetime = { enable = false },
                    type = { enable = false },
                },
                implicitDrops = { enable = false },
                implicitSizedBoundHints = { enable = false },
                lifetimeElisionHints = {
                    enable = "never",
                    useParameterNames = false,
                },
                maxLength = 25,
                parameterHints = { enable = true },
                rangeExclusiveHints = { enable = false },
                renderColons = true,
                typeHints = {
                    enable = false,
                    hideClosureInitialization = false,
                    hideClosureParameter = false,
                    hideNamedConstructor = false,
                },
            },
            server = {
                extraEnv = {
                    ["CARGO_PROFILE_RUST_ANALYZER_INHERITS"] = "dev",
                },
            },
        },
    },
    capabilities = {
        experimental = {
            -- So that we'll receive an `experimental/serverStatus` notification
            serverStatusNotification = true,
        },
    },
    handlers = {
        ["experimental/serverStatus"] = function(_, result, ctx)
            -- If this client hasn't recieved this notification before, and if it has any buffers
            -- where inlay hints are enabled, then disable and re-enabled inlay hints for those
            -- buffers to force them to redraw. Otherwise, inlay hints won't be shown until an edit
            -- is made or the buffer is scrolled.
            if result.quiescent and not _ran_once[ctx.client_id] then
                for bufnr, _ in ipairs(vim.lsp.get_client_by_id(ctx.client_id).attached_buffers) do
                    if vim.lsp.inlay_hint.is_enabled { bufnr = bufnr } then
                        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end
                end
                _ran_once[ctx.client_id] = true
            end
        end,
    },
    on_attach = {
        vim.lsp.config.rust_analyzer.on_attach,
        function(_, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end,
    }
})
vim.lsp.enable('rust_analyzer')

vim.lsp.enable('bashls')

vim.lsp.enable('gopls')

local go_group = vim.api.nvim_create_augroup('go', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = go_group,
    pattern = '*.go',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

local ocaml_group = vim.api.nvim_create_augroup('ocaml', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = ocaml_group,
    pattern = '*.ml',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.lsp.config('texlab', {
    settings = {
        texlab = {
            auxDirectory = "./build",
            build = {
                executable = "tectonic",
                args = {
                    "--synctex",
                    "--keep-logs",
                    "--keep-intermediates",
                    "--outdir",
                    "./build",
                    "-Z",
                    "shell-escape",
                    "%f",
                },
            },
        },
    },
})
vim.lsp.enable('texlab')

local latex_group = vim.api.nvim_create_augroup('latex', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = latex_group,
    pattern = { '*.tex', '*.bib' },
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.lsp.config('pylsp', {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    ignore = {
                        "E201",
                        "E202",
                        "W291",
                    },
                },
            },
        },
    },
})
vim.lsp.enable('pylsp')

local python_group = vim.api.nvim_create_augroup('python', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = python_group,
    pattern = '*.py',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    group = python_group,
    pattern = '*.py',
    callback = function()
        vim.opt_local.textwidth = 79
    end,
})

vim.lsp.config('nil_ls', {
    autostart = true,
    settings = {
        ['nil'] = {
            formatting = {
                command = { "alejandra" },
            },
        },
    },
})
vim.lsp.enable('nil_ls')

local nix_group = vim.api.nvim_create_augroup('nix', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = nix_group,
    pattern = '*.nix',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

vim.lsp.config('tinymist', {
    settings = {
        completion = {
            postfix = false,
        },
        typstExtraArgs = {
            "--features",
            "html",
        },
        systemFonts = true,
    },
})
vim.lsp.enable('tinymist')

vim.lsp.config('lua_ls', {
    settings = {
        Lua = { },
    },
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path..'/.luarc.json') or vim.uv.fs_stat(path..'/.luarc.jsonc')) then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
            }
        })
    end
})
vim.lsp.enable('lua_ls')

vim.lsp.enable('ts_ls')

vim.lsp.enable('unison')


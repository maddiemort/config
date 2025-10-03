local notify = require'notify'

-- Override the default signs shown in the signcolumn for each type of 
-- diagnostic.
local signs = { Error = "☣ ", Warn = "☢ ", Hint = "⚙ ", Info = "❄ " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- parameter hints: "› "
-- other hints: "» "
vim.fn.sign_define("LspInlayHint", { text = "» ", texthl = "LspInlayHint", numhl = "LspInlayHint" })

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        severity_sort = true,
    }
)

vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
    notify(result.message, lvl, {
        title = 'LSP | ' .. client.name,
        -- timeout = 10000,
        keep = function()
            return lvl == 'ERROR' or lvl == 'WARN'
        end,
    })
end

vim.notify = notify

vim.lsp.handlers["textDocument/hover"] = function(_, result, ctx, config)
    config = config or {}
    config.focus_id = ctx.method
    if not (result and result.contents) then
        notify('No information available', 'ERROR')
        return
    end
    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
    if vim.tbl_isempty(markdown_lines) then
        notify('No information available', 'WARN')
        return
    end
    return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
end

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
vim.keymap.set('n', '<leader>s', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'Document Symbols' })
vim.keymap.set('n', '<leader>S', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = 'Workspace Symbols' })

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
                command = { "nixpkgs-fmt" },
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

vim.diagnostic.config({
    virtual_text = {
        prefix = '⚕',
    },
})

vim.lsp.enable('tinymist')

vim.lsp.config('lua_ls', {
    on_init = function(client, result)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
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
                            -- "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                        }
                        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                        -- library = vim.api.nvim_get_runtime_file("", true)
                    }
                }
            })

            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end
})
vim.lsp.enable('lua_ls')

vim.lsp.enable('ts_ls')

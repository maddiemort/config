local lspconfig = require'lspconfig'
local notify = require'notify'

-- Override the default signs shown in the signcolumn for each type of 
-- diagnostic.
local signs = { Error = "☣ ", Warn = "☢ ", Hint = "⚙ ", Info = "❄ " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Documentation' })
vim.keymap.set('n', 'gr', vim.lsp.buf.rename, { desc = 'Rename' })
vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, { desc = 'Code Actions' })

-- Map shortcuts for telescope LSP pickers
vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', { desc = 'Definition' })
vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<cr>', { desc = 'Implementations' })
vim.keymap.set('n', 'gu', '<cmd>Telescope lsp_references<cr>', { desc = 'References' })
vim.keymap.set('n', 'gD', '<cmd>Telescope lsp_type_definitions<cr>', { desc = 'Type Definitions' })
vim.keymap.set('n', 'g0', '<cmd>Telescope lsp_document_symbols<cr>', { desc = 'Document Symbols' })
vim.keymap.set('n', 'gW', '<cmd>Telescope lsp_workspace_symbols<cr>', { desc = 'LSP Workspace Symbols' })
vim.keymap.set('n', '<leader>d', '<cmd>Telescope diagnostics<cr>', { desc = 'Diagnostics' })

lspconfig.bashls.setup {}

-- lspconfig.ccls.setup {}

lspconfig.gopls.setup {}

local go_group = vim.api.nvim_create_augroup('go', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = go_group,
    pattern = '*.go',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

lspconfig.ocamllsp.setup{}

local ocaml_group = vim.api.nvim_create_augroup('ocaml', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = ocaml_group,
    pattern = '*.ml',
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

lspconfig.texlab.setup {
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
}

local latex_group = vim.api.nvim_create_augroup('latex', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = latex_group,
    pattern = { '*.tex', '*.bib' },
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

lspconfig.pylsp.setup {
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
}

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

lspconfig.nil_ls.setup {
    autostart = true,
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixpkgs-fmt" },
            },
        },
    },
}

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


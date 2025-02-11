local cmp_lsp = require'cmp_nvim_lsp'
local capabilities = cmp_lsp.default_capabilities()

vim.lsp.commands['rust-analyzer.triggerParameterHints'] = function()
    local ok, result = pcall(vim.lsp.buf.signature_help)
    if ok then
        return vim.NIL
    else
        return vim.lsp.rpc_response_error(vim.lsp.protocol.ErrorCodes.InternalError, result)
    end
end

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
            },
        },
    },
})

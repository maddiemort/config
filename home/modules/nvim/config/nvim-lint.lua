require'lint'.linters_by_ft = {
    swift = { 'swiftlint' },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("swiftlint", { clear = true }),
    callback = function()
        if not vim.endswith(vim.fn.bufname(), "swiftinterface") then
            require("lint").try_lint()
        end
    end,
})

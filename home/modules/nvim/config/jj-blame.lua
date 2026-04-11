require'jjblame'.setup {
    enabled = true,
    virtual_text_enabled = true,
    virtual_text_column = 100,
    virtual_text_highlight = { "CursorLine", "SpecialComment" },
    ignored_filetypes = { },
    delay = 0,
    on_update = function()
        require'lualine'.refresh()
    end,
}

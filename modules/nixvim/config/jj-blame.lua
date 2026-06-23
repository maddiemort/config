require'jjblame'.setup {
    enabled = true,
    template = 'jjblame_template',
    virtual_text_enabled = true,
    virtual_text_highlight = "SpecialComment",
    delay = 0,
    on_update = function()
        require'lualine'.refresh()
    end,
}

require'jjblame'.setup {
    enabled = true,
    virtual_text_enabled = false,
    template = 'jjblame_template',
    virtual_text_highlight = "SpecialComment",
    delay = 0,
    on_update = function()
        require'lualine'.refresh()
    end,
}

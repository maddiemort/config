vim.g.jjblame_enabled = 1
vim.g.jjblame_message_template = '<author> • <date> • <sha> • <description>'
vim.g.jjblame_message_when_not_committed = 'Not committed yet'
vim.g.jjblame_date_format = '%r'
vim.g.jjblame_highlight_group = "SpecialComment"
vim.g.jjblame_ignored_filetypes = {''}

-- This is disabled because the blame status is currently being displayed in the
-- lualine (see lualine.lua) instead of using virtual text.
vim.g.jjblame_display_virtual_text = 0

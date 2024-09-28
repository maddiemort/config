vim.g.gitblame_enabled = 1
vim.g.gitblame_message_template = '<author> • <date> • <sha> • <summary>'
vim.g.gitblame_message_when_not_committed = 'Not committed yet'
vim.g.gitblame_date_format = '%r'
vim.g.gitblame_highlight_group = "SpecialComment"
vim.g.gitblame_ignored_filetypes = {''}

-- This is disabled because the blame status is currently being displayed in the
-- lualine (see lualine.lua) instead of using virtual text.
vim.g.gitblame_display_virtual_text = 0

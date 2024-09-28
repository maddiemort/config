-- Don't map any keys by default
vim.g.gitgutter_map_keys = 0

-- Use a bar for all the different git status signs in the buffer, so that 
-- they're all just distinguished by colour and not character
vim.g.gitgutter_sign_added = '▏'
vim.g.gitgutter_sign_modified = '▏'
vim.g.gitgutter_sign_removed = '▏'
vim.g.gitgutter_sign_removed_first_line = '▏'
vim.g.gitgutter_sign_modified_removed = '▏'

-- Don't highlight line numbers in a special way
vim.g.gitgutter_highlight_linenrs = 0
vim.cmd('highlight! link SignColumn LineNr')

-- This might reduce performance (especially as the result of interactions with plugins/LSP), so be
-- careful
vim.cmd('set updatetime=500')

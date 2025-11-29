require'telescope'.setup {
    pickers = {
        find_files = {
            hidden = true,
        },
        spell_suggest = {
            layout_strategy = 'cursor',
            theme = 'dropdown',
        },
    },
    extensions = {
        file_browser = {
            hidden = true,
            respect_gitignore = false,
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
                layout_strategy = 'cursor',
            },
        },
    }
}

require'telescope'.load_extension('file_browser')
require'telescope'.load_extension('spell_errors')
require'telescope'.load_extension('ui-select')

local function set_spell_highlights()
  vim.cmd('highlight SpellBad guifg=NONE guibg=NONE gui=underdotted guisp=NvimLightRed')
  vim.cmd('highlight SpellCap guifg=NONE guibg=NONE gui=underdotted guisp=NvimLightYellow')
  vim.cmd('highlight SpellLocal guifg=NONE guibg=NONE gui=underdotted guisp=NvimLightGreen')
  vim.cmd('highlight SpellRare guifg=NONE guibg=NONE gui=underdotted guisp=NvimLightCyan')
end

local spell_group = vim.api.nvim_create_augroup('spell_highlight', {})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = spell_group,
    pattern = '*',
    callback = set_spell_highlights,
})

-- This has to be run after the spell_errors extension is loaded
set_spell_highlights()

-- Map shortcuts for a few telescope pickers
vim.keymap.set('n', '<leader>t', '<cmd>Telescope<cr>', { desc = 'Telescope' })
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = 'Files' })
vim.keymap.set('n', '<leader>b', '<cmd>Telescope buffers<cr>', { desc = 'Buffers' })
vim.keymap.set('n', '<C-/>', '<cmd>Telescope live_grep<cr>', { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>f', '<cmd>Telescope file_browser<cr>', { desc = 'File Browser' })
vim.keymap.set(
    'n',
    '<leader>c',
    function()
        require'telescope.builtin'.find_files {
            find_command = {
                'bash',
                '-c',
                'jj resolve --list | awk \'{print$1}\'',
            },
            prompt_title = 'Conflicted Files',
        }
    end,
    {
        desc = 'Conflicted Files',
    }
)
vim.keymap.set(
    'n',
    '<leader>S',
    function()
        require'telescope'.extensions.spell_errors.spell_errors()
    end,
    {
        desc = 'Spelling Errors',
    }
)
vim.keymap.set(
    'n',
    '<leader>s',
    function()
        require'telescope.builtin'.spell_suggest()
    end,
    {
        desc = 'Spelling Suggestions',
    }
)

vim.keymap.set('n', 'ghg', '<cmd>Telescope git_status<cr>', { desc = 'Git Status' })
vim.keymap.set('n', 'ghf', '<cmd>Telescope git_commits<cr>', { desc = 'Git History' })
vim.keymap.set('n', 'ghF', '<cmd>Telescope git_bcommits<cr>', { desc = 'Git File History' })
vim.keymap.set('n', 'gha', '<cmd>Telescope git_stash<cr>', { desc = 'Git Stashes' })
vim.keymap.set('n', 'ghs', '<cmd>Telescope git_branches<cr>', { desc = 'Git Branches' })

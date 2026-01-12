-- ==================
-- KEYBOARD SHORTCUTS
-- ==================

-- Suspend nvim
vim.keymap.set('n', '<leader>z', '<cmd>sus<cr>', { desc = 'Suspend' })

-- Copy and paste to/from system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { desc = 'Yank to System' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from System' })
vim.keymap.set('n', '<leader>P', '"+P', { desc = 'Paste Above from System' })

vim.keymap.set(
  'n',
  '<leader>l',
  [[<cmd>let @+ = expand("%") . ":" . line(".")<cr>]],
  { desc = 'Copy Current File and Line Number' }
)
vim.keymap.set(
  'v',
  '<leader>l',
  [[<cmd>let @+ = expand("%") . ":" . line("v") . "-" . line(".")<cr>]],
  { desc = 'Copy Current File and Range of Lines' }
)

vim.keymap.set(
  'n',
  '<leader>hl',
  [[<cmd>let @+ = expand("%") . " line " . line(".")<cr>]],
  { desc = 'Copy Human-Readable Current File and Line Number' }
)
vim.keymap.set(
  'v',
  '<leader>hl',
  [[<cmd>let @+ = expand("%") . " lines " . line("v") . " to " . line(".")<cr>]],
  { desc = 'Copy Human-Readable Current File and Range of Lines' }
)

vim.keymap.set(
  'n',
  '<leader>gl',
  [[<cmd>let base = system("git remote get-url origin | sed -e's|:|/|' -e 's|git@|https://|' -e 's|.git$||'") | let commit = system("git rev-parse HEAD") | let @+ = trim(base) . "/blob/" . trim(commit) . "/" . expand("%") . "#L" . line(".")<cr>]],
  { desc = 'Copy GitHub Link to Current File and Line Number' }
)
vim.keymap.set(
  'v',
  '<leader>gl',
  [[<cmd>let base = system("git remote get-url origin | sed -e's|:|/|' -e 's|git@|https://|' -e 's|.git$||'") | let commit = system("git rev-parse HEAD") | let @+ = trim(base) . "/blob/" . trim(commit) . "/" . expand("%") . "#L" . line("v") . "-L" . line(".")<cr>]],
  { desc = 'Copy GitHub Link to Current File and Range of Lines' }
)

-- Quick switch between the last two buffers using <leader><leader>
vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = 'Quick Switch Buffers' })

-- Clear search highlighting
vim.keymap.set('n', '<leader>/', '<cmd>noh<cr>', { desc = 'Clear Search Highlighting' })

-- Create splits with <leader>s and a direction
vim.keymap.set('n', '<leader>sh', '<cmd>leftabove vnew<cr>', { desc = 'Split Left' })
vim.keymap.set('n', '<leader>sj', '<cmd>rightbelow new<cr>', { desc = 'Split Below' })
vim.keymap.set('n', '<leader>sk', '<cmd>leftabove new<cr>', { desc = 'Split Above' })
vim.keymap.set('n', '<leader>sl', '<cmd>rightbelow vnew<cr>', { desc = 'Split Right' })

-- Move between splits with C and a direction
vim.keymap.set('n', '<C-H>', '<C-W><C-H>', { desc = 'Move to Split Left' })
vim.keymap.set('n', '<C-J>', '<C-W><C-J>', { desc = 'Move to Split Below' })
vim.keymap.set('n', '<C-K>', '<C-W><C-K>', { desc = 'Move to Split Above' })
vim.keymap.set('n', '<C-L>', '<C-W><C-L>', { desc = 'Move to Split Right' })

-- Run make from the current directory
vim.keymap.set('n', 'M', '<cmd>make<cr>', { desc = 'Run `make`' })

-- Go to next/previous diagnostic, error or warning
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous Diagnostic' })
vim.keymap.set('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Next Error' })
vim.keymap.set('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Previous Error' })
vim.keymap.set('n', ']w', function() vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN } }) end, { desc = 'Next Warning/Error' })
vim.keymap.set('n', '[w', function() vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN } }) end, { desc = 'Previous Warning/Error' })

local spellbinds = {
    { bind = "<leader>mg", command = "zg", prompt = "Mark spelled correctly in:", desc = "Mark Word as Spelled Correctly" },
    { bind = "<leader>ug", command = "zug", prompt = "Undo mark spelled correctly in:", desc = "Undo Mark Word as Spelled Correctly" },
    { bind = "<leader>mw", command = "zw", prompt = "Mark spelled wrong in:", desc = "Mark Word as Spelled Wrong" },
    { bind = "<leader>uw", command = "zuw", prompt = "Undo mark spelled wrong in:", desc = "Undo Mark Word as Spelled Wrong" },
}
for _, spellbind in ipairs(spellbinds) do
    vim.keymap.set(
        {'n', 'v'},
        spellbind.bind,
        function()
            if not vim.o.spell or string.len(vim.bo.spellfile) == 0 then
                return
            end

            local spellfiles = {}
            for spellfile in string.gmatch(vim.bo.spellfile, '([^,]+)') do
                spellfiles[#spellfiles + 1] = spellfile
            end

            vim.ui.select(spellfiles, {
                prompt = spellbind.prompt,
            }, function(_, index)
                if index ~= nil then
                    vim.cmd.normal { index .. spellbind.command }
                end
            end)
        end,
        { desc = spellbind.desc }
    )
end

-- =================
-- LANGUAGE SETTINGS
-- =================

-- -----
-- Typst
-- -----

local typst_group = vim.api.nvim_create_augroup('typst', {})
vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
    group = typst_group,
    pattern = '*.typ',
    callback = function()
        vim.bo.textwidth = 100

        vim.opt_local.spell = true
        vim.bo.spelllang = "en_gb"
        vim.bo.spellcapcheck = ""

        local stop = nil
        if vim.startswith(vim.fn.getcwd(), vim.env.HOME) then
            stop = vim.env.HOME
        end

        local found_files = vim.fs.find(
            ".vimspell.utf-8.add",
            {
                upward = true,
                limit = math.huge,
                type = "file",
                stop = stop,
            }
        )

        local spellfile = ""
        for i, found_file in ipairs(found_files) do
            if i ~= 1 then
                spellfile = spellfile .. ","
            end
            spellfile = spellfile .. found_file
        end

        if #found_files ~= 0 then
            spellfile = spellfile .. ","
        end
        spellfile = spellfile .. vim.fn.stdpath('data') .. "/site/spell/en.utf-8.add"

        vim.bo.spellfile = spellfile
    end,
})

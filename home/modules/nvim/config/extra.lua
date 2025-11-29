-- ==================
-- KEYBOARD SHORTCUTS
-- ==================

-- Quick-save with <leader>w
-- vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Write' })

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

-- Go to next/previous diagnostic
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next Diagnostic' })
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Previous Diagnostic' })
vim.keymap.set('n', ']e', function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Next Error' })
vim.keymap.set('n', '[e', function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, { desc = 'Previous Error' })
vim.keymap.set('n', ']w', function() vim.diagnostic.jump({ count = 1, severity = { min = vim.diagnostic.severity.WARN } }) end, { desc = 'Next Warning/Error' })
vim.keymap.set('n', '[w', function() vim.diagnostic.jump({ count = -1, severity = { min = vim.diagnostic.severity.WARN } }) end, { desc = 'Previous Warning/Error' })

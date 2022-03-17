local opts = { noremap = true }
local keymap = vim.api.nvim_set_keymap
local fmt = string.format

-- keymap('n', '<c-s>', ':w<CR>', {})
-- keymap('i', '<c-s>', '<Esc>:w<CR>a', {})

-- use alt+hjkl to move between split/vsplit panels
for _, mode in ipairs({'n', 't'}) do
  for _, k in ipairs({'h', 'j', 'k', 'l'}) do
    keymap(mode, fmt('<c-%s>', k), fmt('<c-w>%s', k), opts)
  end
end

-- turn terminal to normal mode with escape
keymap('t', '<Esc>', '<C-\\><C-n>', opts)

keymap('n', '<C-b>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

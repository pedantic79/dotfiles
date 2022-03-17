-- global
require('user.plugins')
require('user.lsp')
require('user.lsp-installer')
require('user.completion')
require('user.keybindings')
require('user.config')
require('user.treesitter')


vim.api.nvim_set_var('gruvbox_contrast_dark', 'soft')
vim.api.nvim_set_var('gruvbox_material_background', 'soft')
vim.api.nvim_set_var('airline_powerline_fonts', 1)

vim.cmd [[command! Hidechars set invlist invnumber | GitGutterToggle]]
vim.cmd [[colorscheme morning]]
vim.cmd [[silent! colorscheme dracula]]
vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').gofmt() ]], false)
vim.opt.background = 'dark'

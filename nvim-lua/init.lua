-- global
require('plugins')
require('lsp')
require('lsp-installer')
require('completion')
require('keybindings')
require('config')
require('treesitter')
-- require('go').setup({})


vim.api.nvim_set_var('gruvbox_contrast_dark', 'soft')
vim.api.nvim_set_var('gruvbox_material_background', 'soft')
vim.api.nvim_set_var('airline_powerline_fonts', 1)

vim.cmd [[command! Hidechars set invlist invnumber | GitGutterToggle]]
vim.cmd [[colorscheme slate]]
vim.cmd [[silent! colorscheme dracula]]
vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').gofmt() ]], false)
require('go').setup()

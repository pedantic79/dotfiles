vim.opt.number = true
vim.opt.listchars = { tab = '⇥ ', trail = '·', precedes = '«', extends = '»', eol = '¬' }
vim.opt.list = true
vim.opt.spell = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.colorcolumn = '81,121'
vim.opt.encoding = 'UTF-8'

-- open new split panes to right and below
vim.opt.splitbelow = true
vim.opt.splitright = true


if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

vim.opt.background = 'dark'

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.listchars = { tab = "⇥ ", trail = "·", precedes = "«", extends = "»", eol = "¬" }
vim.opt.colorcolumn = "81,121"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.api.nvim_create_user_command("Hidechars", function()
  vim.o.signcolumn = vim.o.signcolumn == "yes" and "no" or "yes"
  vim.o.list = not vim.o.list
  vim.o.relativenumber = not vim.o.relativenumber
  vim.o.number = not vim.o.number
  vim.cmd.IBLToggle()
end, {})

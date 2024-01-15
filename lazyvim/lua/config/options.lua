-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.listchars = { tab = "⇥ ", trail = "·", precedes = "«", extends = "»", eol = "¬" }
vim.opt.colorcolumn = "81,121"

vim.api.nvim_create_user_command("Hidechars", function()
  vim.cmd([[set invlist invrelativenumber invnumber]])
  vim.cmd([[IBLToggle]])
end, {})

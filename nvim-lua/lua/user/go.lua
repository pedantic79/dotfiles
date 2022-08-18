local status_ok, go = pcall(require, 'go')
if not status_ok then
  return
end

go.setup{}
vim.api.nvim_exec([[ autocmd FileType go autocmd BufWritePre <buffer> silent GoImport]], false)


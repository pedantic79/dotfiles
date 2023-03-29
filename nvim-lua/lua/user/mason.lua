local status_ok, lsp_installer = pcall(require, 'mason')
if not status_ok then
  return
end

lsp_installer.setup({
  ui = {
      icons = {
          server_installed = '✓',
          server_pending = '➜',
          server_uninstalled = '✗'
      }
  }
})

-- Include the servers you want to have installed by default below
local servers = {}

if vim.fn.executable('node') == 1 then
  table.insert(servers, 'bashls')
  table.insert(servers, 'jsonls')
  table.insert(servers, 'yamlls')
  if vim.fn.executable('docker') == 1 then
    table.insert(servers, 'dockerls')
  end
end

if vim.fn.executable('go') == 1 then
  table.insert(servers, 'gopls')
  table.insert(servers, 'golangci_lint_ls')
end

if vim.fn.executable('cargo') == 1 then
   table.insert(servers, 'taplo')
   table.insert(servers, 'rust_analyzer')
end

if vim.fn.executable('black') == 1 then
  table.insert(servers, 'pylsp')
  table.insert(servers, 'pyright') -- npm
  table.insert(servers, 'jedi_language_server')
end

local lspconfig = require("lspconfig")

require("mason-lspconfig").setup({
  ensure_installed = servers,
})

for _, server in pairs(servers) do
  local opts = {
    on_attach = on_attach,
  }
  if server == 'rust_analyzer' then
    -- use rust-tools instead of rust_analyzer
    local rust_tools = require("rust-tools")
    rust_tools.setup {
      server = {
        on_attach = function (_, bufnr)
          -- vim.keymap.set("n", "<C-space>", rust_tools.hover_actions.hover_actions, { buffer = bufnr })
          vim.keymap.set("n", "<C-.>", rust_tools.code_action_group.code_action_group, { buffer = bufnr })
        end,
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy'
            }
          }
        }
      },
      tools = {
        inlay_hints = {
          parameter_hints_prefix = "ﰯ", -- nf-mdi-border_left
          other_hints_prefix = "", -- nf-oct-triangle_right
        }
      }
    }
  else
    lspconfig[server].setup(opts)
  end
end

vim.api.nvim_create_user_command("LspInstallAll", function()
  vim.cmd("LspInstall " .. table.concat(servers, " "))
end, {})

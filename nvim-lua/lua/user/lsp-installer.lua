local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

lsp_installer.on_server_ready(function(server)
  local opts = {}
  server:setup(opts)
end)

lsp_installer.on_server_ready(function(server)
  local opts = {}

  if server.name == "rust_analyzer" then
    -- Initialize the LSP via rust-tools instead
    require("rust-tools").setup {
        -- The "server" property provided in rust-tools setup function are the
        -- settings rust-tools will provide to lspconfig during init.            --
        -- We merge the necessary settings from nvim-lsp-installer (server:get_default_options())
        -- with the user's own settings (opts).
        server = vim.tbl_deep_extend("force", server:get_default_options(), opts),
    }
    server:attach_buffers()
    -- Only if standalone support is needed
    require("rust-tools").start_standalone_if_required()
  else
    server:setup(opts)
  end
end)

lsp_installer.settings({
  ui = {
      icons = {
          server_installed = "✓",
          server_pending = "➜",
          server_uninstalled = "✗"
      }
  }
})

-- Include the servers you want to have installed by default below
local servers = {'taplo'}

if vim.fn.executable('node') == 1 then
  table.insert(servers, 'bashls')
  table.insert(servers, 'jsonls')
  table.insert(servers, 'yamlls')
end

if vim.fn.executable('go') == 1 then
  table.insert(servers, 'gopls')
end

if vim.fn.executable('cargo') == 1 then
  table.insert(servers, 'rust_analyzer')
end

if vim.fn.executable('docker') == 1 then
  table.insert(servers, 'dockerls')
end

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

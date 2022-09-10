local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
  return
end

local lspkind_status_ok, lspkind = pcall(require, 'lspkind')
if not lspkind_status_ok then
  return
end

cmp.setup {
  mapping = {
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end
  },
  sources = {
    { name = 'path' },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'buffer', keyword_length = 5 },
    { name = 'vsnip' }
  },
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },

  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = '[buf]',
        nvim_lsp = '[LSP]',
        nvim_lua = '[api]',
        path = '[path]',
      }
    }
  },

  experimental = {
    native_menu = false,
    ghost_text = true,
  }
}

local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  return
end

local languages = {
  "bash",
  "css",
  "dockerfile",
  "graphql",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "make",
  "norg",
  "perl",
  "regex",
  "scss",
  "toml",
  "typescript",
  "vim",
  "yaml"
}

if vim.fn.executable('go') == 1 then
  table.insert(languages, 'go')
  table.insert(languages, 'gomod')
end

if vim.fn.executable('cargo') == 1 then
  table.insert(languages, 'rust')
end

if vim.fn.executable('ruby') == 1 then
  table.insert(languages, 'ruby')
end

if vim.fn.executable('python') == 1 then
  table.insert(languages, 'python')
end

if vim.fn.executable('kotlin') == 1 then
  table.insert(languages, 'kotlin')
end

if vim.fn.executable('javac') == 1 then
  table.insert(languages, 'java')
end

configs.setup {
  ensure_installed = languages, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = { "" }, -- List of parsers to ignore installing
  autopairs = {
    enable = true,
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { "yaml" } },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}

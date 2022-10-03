local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

local ignore_list = { 'agda', 'astro', 'beancount', 'bibtex', 'blueprint',
  'commonlistp', 'cooklang', 'cuda', 'd', 'dart', 'devicetree', 'eex', 'elixir',
  'elm', 'elvish', 'embedded_template', 'erlang', 'fennel', 'foam', 'fortran',
  'fusion', 'gdscript', 'gleam', 'glimmer', 'glsl', 'godot_resource', 'hack',
  'hcl', 'heex', 'hjson', 'hlsl', 'hocon', 'julia', 'jsonnet', 'latex',
  'lalrpop', 'ledger', 'm68k', 'menhir', 'meson', 'ninja', 'nix', 'pascal',
  'phpdoc', 'pioasm', 'prisma', 'proto', 'pug', 'ql', 'qmljs', 'query', 'r',
  'racket', 'rasi', 'rego', 'rnoweb', 'rst', 'scala', 'scheme', 'slint',
  'solidity', 'sparql', 'sql', 'supercollider', 'surface', 'svelte', 'sxhkdrc',
  'teal', 'tiger', 'tlaplus', 'todotxt', 'turtle', 'twig', 'v', 'vala',
  'verilog', 'vue', 'wgsl', 'yang' }

configs.setup {
  ensure_installed = 'all', -- one of 'all', 'maintained' (parsers with maintainers), or a list of languages
  sync_install = true, -- install languages synchronously (only applied to `ensure_installed`)
  ignore_install = ignore_list, -- List of parsers to ignore installing
  autopairs = {
    enable = true,
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { '' }, -- list of language that will be disabled
    additional_vim_regex_highlighting = true,
  },
  indent = { enable = true, disable = { 'yaml' } },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}

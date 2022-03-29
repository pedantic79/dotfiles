-- global
require('user.plugins')
require('user.lsp')
require('user.lsp-installer')
require('user.completion')
require('user.keybindings')
require('user.config')
require('user.treesitter')
require('user.nvim-tree')

vim.opt.background = 'dark'
vim.api.nvim_set_var('gruvbox_contrast_dark', 'soft')
vim.api.nvim_set_var('gruvbox_material_background', 'soft')
vim.api.nvim_set_var('airline_powerline_fonts', 1)

local colors = vim.fn.getcompletion('', 'color')

local has_value = function(t, val)
    for k, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

local scheme = 'dracula'
if not has_value(colors, scheme) then
    scheme = 'morning'
end

vim.cmd('colorscheme ' .. scheme)
vim.cmd [[command! Hidechars set invlist invnumber | GitGutterToggle]]
vim.cmd [[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]]

require('user.go')

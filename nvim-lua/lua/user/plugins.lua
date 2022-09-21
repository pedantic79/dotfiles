local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'


if fn.empty(fn.glob(install_path)) > 0 then
  local packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup({function(use)
  -- My plugins here
  use { 'wbthomason/packer.nvim', opt = true }

  -- Theme
  use 'dracula/vim'
  use 'morhetz/gruvbox'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'airblade/vim-gitgutter'

  -- GUI Enhancement
  use 'machakann/vim-highlightedyank'
  -- use 'nvim-lua/plenary.nvim'
  -- use 'nvim-lua/popup.nvim'

  -- LSP
  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
  }
  use 'simrat39/rust-tools.nvim'
  use 'onsails/lspkind-nvim'

  -- File exporer with icons
  use 'kyazdani42/nvim-tree.lua'
  use 'kyazdani42/nvim-web-devicons'

  -- Completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/vim-vsnip'

  -- use 'f3fora/cmp-spell'

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }

  -- Languages
  -- use 'crispgm/nvim-go'
  if vim.fn.executable('go') == 1 then
    use 'ray-x/go.nvim'
  end


  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end,
config = {
  display = {
    open_fn = function()
      return require('packer.util').float({ border = 'single' })
    end
  }
}})

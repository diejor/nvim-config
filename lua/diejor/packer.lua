--) This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.4',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'ellisonleao/gruvbox.nvim' }
  use({ 'rose-pine/neovim', as = 'rose-pine' })
  use { 'mbbill/undotree' }
  use({
    "aserowy/tmux.nvim",
    config = function() return require("tmux").setup() end
})

  use {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    'hrsh7th/nvim-cmp', -- Autocompletion plugin
    'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
    'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
    'L3MON4D3/LuaSnip', -- Snippets plugin
  }

  use { 'tpope/vim-fugitive' }
  use {
      "folke/trouble.nvim",
      config = function()
          require("trouble").setup {
              icons = false,
              -- your configuration comes here
              -- or leave it empty to use the default settings
              -- refer to the configuration section below
          }
      end
  }

  use { "mfussenegger/nvim-dap" }
  use { "mfussenegger/nvim-jdtls" }
  use { "theHamsta/nvim-dap-virtual-text" }
  use { "rcarriga/nvim-dap-ui" }
  use { "github/copilot.vim" }
  use { "lervag/vimtex" }
end)


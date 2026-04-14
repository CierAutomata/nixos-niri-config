vim.g.mapleader = " "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "neovim/lspconfig" },
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim" },
  { "lewis6991/gitsigns.nvim" },
  { 
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.nil_ls.setup{}
      lspconfig.pyright.setup{}
      lspconfig.ts_ls.setup{}
    end
  },
})

-- Appearance
require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
vim.cmd.colorscheme "catppuccin"
require('lualine').setup { options = { theme = 'catppuccin' } }

-- Functionality
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
require("nvim-tree").setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

-- LSP & Treesitter
local lspconfig = require('lspconfig')
lspconfig.nil_ls.setup{}
require'nvim-treesitter.configs'.setup { 
  highlight = { enable = true },
  ensure_installed = { "nix", "lua" } 
}

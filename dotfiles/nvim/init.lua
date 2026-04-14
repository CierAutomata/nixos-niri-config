vim.g.mapleader = " "

-- 1. Lazy.nvim Bootstrapping
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Plugin Setup
require("lazy").setup({
  -- UI
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  
  -- Tools
  { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim" },
  { "lewis6991/gitsigns.nvim" },
  
  -- Treesitter
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup { 
        highlight = { enable = true },
        ensure_installed = { "nix", "lua" } 
      }
    end
  },

  -- LSP & Completion
  { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip" } },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Der neue Standard (Neovim 0.11+) nutzt intern vim.lsp.config
      -- Wir konfigurieren hier nil_ls (Nix) und pyright (Python)
      
      -- nil_ls Setup
      if vim.lsp.config then
        -- Moderne Syntax (0.11+)
        vim.lsp.config["nil_ls"] = {
          setup = {},
        }
        vim.lsp.config["pyright"] = {
          setup = {},
        }
      else
        -- Fallback für 0.10.x
        local lspconfig = require('lspconfig')
        lspconfig.nil_ls.setup{}
        lspconfig.pyright.setup{}
      end
    end,
  },
})

-- 3. Appearance Settings
require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
vim.cmd.colorscheme "catppuccin"
require('lualine').setup { options = { theme = 'catppuccin' } }

-- 4. General Options & Keymaps
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

require("nvim-tree").setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

-- Das "require('lspconfig')" ganz am Ende haben wir gelöscht, 
-- da die Konfiguration jetzt sicher innerhalb des Lazy-Blocks stattfindet.
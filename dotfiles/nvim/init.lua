vim.g.mapleader = " "

-- 1. Lazy.nvim Bootstrapping
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Bootstrapping lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("Done. Restart Neovim!")
end
vim.opt.rtp:prepend(lazypath)

-- Prüfen, ob lazy wirklich da ist, bevor wir es aufrufen
local ok, lazy = pcall(require, "lazy")
if not ok then
  return -- Stoppt die Ausführung, wenn lazy noch nicht geladen werden konnte
end
vim.pack.add { { src = "https://github.com/catppuccin/nvim", name = "catppuccin"} }
--vim.pack.add { { src = "https://github.com/rose-pine/neovim", name = "rose-pine"} }
-- 2. Plugin Setup
require("lazy").setup({
  -- UI
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
      -- Wir nutzen pcall, falls das Modul noch fehlt
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup({
          highlight = { enable = true },
          ensure_installed = { "nix", "lua" },
        })
      end
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
vim.cmd.colorscheme "catppuccin"
--vim.cmd "rose-pine"
-- 4. General Options & Keymaps
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 2   
vim.opt.shiftwidth = 2 
vim.opt.softtabstop = 2
vim.opt.expandtab = true

require("nvim-tree").setup()
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

-- Das "require('lspconfig')" ganz am Ende haben wir gelöscht, 
-- da die Konfiguration jetzt sicher innerhalb des Lazy-Blocks stattfindet.

{ pkgs, ... }:

{
  home.stateVersion = "24.05";

  # --- ALACRITTY CONFIG ---
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.9;
      window.padding = { x = 10; y = 10; };
      font.normal.family = "JetBrainsMono Nerd Font";
      
      # Catppuccin Mocha Colors
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        cursor = { text = "#1e1e2e"; cursor = "#f5e0dc"; };
        normal = {
          black = "#45475a"; red = "#f38ba8"; green = "#a6e3a1"; yellow = "#f9e2af";
          blue = "#89b4fa"; magenta = "#f5c2e7"; cyan = "#94e2d5"; white = "#bac2de";
        };
      };
    };
  };

  # --- NEOVIM IDE CONFIG ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      lua-language-server nil pyright ripgrep fd gcc
      nodePackages.typescript-language-server
    ];
  };

  xdg.configFile."nvim/init.lua".text = ''
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
  '';

  home.packages = with pkgs; [
    firefox
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
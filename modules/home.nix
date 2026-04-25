{ pkgs, config, osConfig, ... }:

let
  dot = osConfig.myConfig.configDir + "/dotfiles";
in
{
  home.stateVersion = "26.05";
  home.username = osConfig.myConfig.userName;
  home.homeDirectory = "/home/${osConfig.myConfig.userName}";

  home.packages = with pkgs; [
    neovim
    gh
    alacritty
    noctalia-shell
    firefox
    brave
    code
    yazi
    nerd-fonts.jetbrains-mono
    pywalfox-native
    vscode
    brave
    vesktop
    spotify
    udiskie
    xdg-utils
    nautilus
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.plasma-workspace
    kdePackages.kio-fuse
    kdePackages.kio-extras
    nwg-look
    dracula-theme
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    remmina
    freerdp
    nwg-displays
  ];

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink (dot + "/hypr/");
    "niri".source = config.lib.file.mkOutOfStoreSymlink (dot + "/niri/");
    "nvim".source = config.lib.file.mkOutOfStoreSymlink (dot + "/nvim/");
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/alacritty/");
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink (dot + "/noctalia/");
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink (dot + "/fastfetch/");
    "fish".source = config.lib.file.mkOutOfStoreSymlink (dot + "/fish/");
    "kitty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/kitty/");
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink (dot + "/.bashrc");
  };
  programs.git = {
    enable = true;
    userName = "CierAutomata";
    userEmail = "CierAutomata@pm.me";
  };

  #programs.fish.enable = true;
  
  home.pointerCursor = {
  gtk.enable = true;
  x11.enable = true;
  package = pkgs.bibata-cursors;
  name = "Bibata-Modern-Classic";
  size = 16;
  };
}

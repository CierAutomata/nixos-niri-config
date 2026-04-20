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
    discord
    firefox
    brave
    code
    yazi
    nerd-fonts.jetbrains-mono
    pywalfox-native
  ];

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink (dot + "/hypr/");
    "niri".source = config.lib.file.mkOutOfStoreSymlink (dot + "/niri/");
    "nvim".source = config.lib.file.mkOutOfStoreSymlink (dot + "/nvim/");
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/alacritty/");
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink (dot + "/noctalia/");
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink (dot + "/.bashrc");
  };

  programs.git = {
    enable = true;
    userName = "CierAutomata";
    userEmail = "CierAutomata@pm.me";
  };
}

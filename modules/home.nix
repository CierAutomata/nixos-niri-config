{ pkgs, config, ... }:

let
  repo = "${config.home.homeDirectory}/repos/nixos-config";
  dot = repo + "/dotfiles";
in

{
  home.stateVersion = "26.05";
  home.username = "cier"; # <--- HIER DEINEN USER EINTRAGEN
  home.homeDirectory = "/home/cier";

  # Pakete installieren, aber nicht über Nix konfigurieren
  home.packages = with pkgs; [
    hyprland
    alacritty
    noctalia-shell
    discord
    neovim
    gh
    nerd-fonts.jetbrains-mono
  ];

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink (dot + "/hypr");
    "nvim".source = config.lib.file.mkOutOfStoreSymlink (dot + "/nvim");
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink (dot + "/alacritty");
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink (dot + "/noctalia");
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink (dot + "/.bashrc");
  };
  
  # Git Identität (die bleibt am besten in Nix, da sie sich selten ändert)
  programs.git = {
    enable = true;
    userName = "CierAutomata";
    userEmail = "CierAutomata@pm.me";
    #extraConfig = {
    #  url = {
    #    "git@github.com" = {
    #      insteadOf = "https://github.com";
    #    };
    #  };
    #};
  };

}

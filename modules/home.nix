{ pkgs, config, ... }:

{
  home.stateVersion = "24.05";
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
    #libnotify
    nerd-fonts.jetbrains-mono
  ];

  # --- OPTION 1: SYMKLINKS ZU DEINEN DOTFILES ---
  
  # Das hier verknüpft deine echten Dateien im Home-Verzeichnis.
  # Die Quellen liegen im Repo und werden mit mkOutOfStoreSymlink verlinkt.
  
  xdg.configFile = {
    # Hyprland
    "hypr".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/hypr;

    # Neovim (den ganzen Ordner verlinken!)
    "nvim".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/nvim;

    # Alacritty
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/alacritty;

    # Noctalia (den ganzen Ordner verlinken!)
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/noctalia;
  };

  home.file = {
    ".bashrc".source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/.bashrc;
  };
  
#  services.mako = {
#    enable = true;
#    defaultTimeout = 5000;
#    backgroundColor = "#1e1e2e";
#  };

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

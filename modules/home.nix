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
  
  # Das hier verknüpft deine echten Dateien im Home-Verzeichnis
  # Ändere "/home/deinName/nixos-config/..." zu deinem tatsächlichen Pfad!
  
  xdg.configFile = {
    # Hyprland
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/hypr";
    
    "../.bashrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/.bashrc"; 

    # Neovim (den ganzen Ordner verlinken!)
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/nvim";
    
    # Alacritty
    "alacritty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/alacritty";
    
    # Noctalia (den ganzen Ordner verlinken!)
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/dotfiles/noctalia";
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

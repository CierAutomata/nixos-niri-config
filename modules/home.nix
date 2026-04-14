{ pkgs, ... }:

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
    nerd-fonts.jetbrains-mono
  ];

  # --- OPTION 1: SYMKLINKS ZU DEINEN DOTFILES ---
  
  # Das hier verknüpft deine echten Dateien im Home-Verzeichnis
  # Ändere "/home/deinName/nixos-config/..." zu deinem tatsächlichen Pfad!
  
  xdg.configFile = {
    # Hyprland
    "hypr/hyprland.conf".source = config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/nixos-config/dotfiles/hyprland.conf";
    
    # Neovim (den ganzen Ordner verlinken!)
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/nixos-config/dotfiles/nvim";
    
    # Alacritty
    "alacritty/alacritty.toml".source = config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/nixos-config/dotfiles/alacritty.toml";
    
    # Noctalia (den ganzen Ordner verlinken!)
    "noctalia".source = config.lib.file.mkOutOfStoreSymlink "${home.homeDirectory}/nixos-config/dotfiles/noctalia";
  };

  # Git Identität (die bleibt am besten in Nix, da sie sich selten ändert)
  programs.git = {
    enable = true;
    userName = "CierAutomata";
    userEmail = "CierAutomata@pm.me";
  };

}

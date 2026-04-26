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
    claude-code
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
    cava
    theclicker
  ];

  xdg.configFile."hypr-host.conf".text = ''
    source = ${dot}/hypr/hosts/${osConfig.networking.hostName}.conf
  '';

  xdg.configFile."niri-host.kdl".text = ''
    include "${dot}/niri/hosts/${osConfig.networking.hostName}.kdl"
  '';

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
  # Override Steam's desktop entry to neutralize the global GDK scaling vars
  # (GDK_SCALE=2/GDK_DPI_SCALE=0.75 are tuned for DP-3 at 1.5x; Steam runs on HDMI-A-4 at 1.0x)
  xdg.desktopEntries.steam = {
    name = "Steam";
    exec = "env GDK_SCALE=1 GDK_DPI_SCALE=1 STEAM_FORCE_DESKTOPUI_SCALING=1 steam %U";
    icon = "steam";
    type = "Application";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };

  programs.git = {
    enable = true;
    settings.user.name = "CierAutomata";
    settings.user.email = "CierAutomata@pm.me";
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

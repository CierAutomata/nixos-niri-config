{ pkgs, config, osConfig, inputs, ... }:

let
  dot = osConfig.myConfig.configDir + "/dotfiles";
  vm-curator = pkgs.callPackage ../packages/vm-curator/default.nix {};
in
{
  home.stateVersion = "26.05";
  home.username = osConfig.myConfig.userName;
  home.homeDirectory = "/home/${osConfig.myConfig.userName}";

  home.packages = with pkgs; [
    vm-curator
    neovim
    gh
    alacritty
    kitty
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
    perlPackages.FileMimeInfo
    lua51Packages.luarocks-nix
    lua51Packages.lua
    rclone
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
    sox
    fastfetch
    timeshift
    btop
    cmatrix
    rustc
    cargo
    wofi
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
  xdg.desktopEntries.kitty-yazi = {
    name = "Yazi (Kitty)";
    exec = "kitty -- yazi %f";
    icon = "yazi";
    type = "Application";
    mimeType = [ "inode/directory" "inode/mount-point" "x-scheme-handler/file" ];
    categories = [ "FileManager" "System" ];
    noDisplay = true;
  };

  xdg.desktopEntries.steam = {
    name = "Steam";
    exec = "env GDK_SCALE=1 GDK_DPI_SCALE=1 STEAM_FORCE_DESKTOPUI_SCALING=1 steam %U";
    icon = "steam";
    type = "Application";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };

  # Sync-Status prüfen:
  #   systemctl --user status rclone-sync.timer    # wann läuft er das nächste Mal
  #   systemctl --user status rclone-sync.service  # letzter Sync erfolgreich?
  #   journalctl --user -u rclone-sync.service     # detaillierte Logs
  systemd.user.services.rclone-sync = {
    Unit = {
      Description = "Proton Drive Sync";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.rclone}/bin/rclone bisync proton:${osConfig.networking.hostName}/Pictures/Wallpapers %h/Pictures/Wallpapers --create-empty-src-dirs --resilient --config %h/.config/rclone/rclone.conf";
    };
  };

  systemd.user.timers.rclone-sync = {
    Unit.Description = "Proton Drive Sync Timer";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30min";
    };
    Install.WantedBy = [ "timers.target" ];
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

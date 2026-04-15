{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
  ];
  networking.hostName = "flocke";


  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" "disk" "storage" ];
    hashedPasswordFile = config.sops.secrets.user-password.path;
  };
  users.mutableUsers = false; # Das ist der wichtigste Schalter!

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml; # Pfad zu deiner verschlüsselten Datei
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/cier/.config/sops/age/keys.txt"; 
      generateKey = true;
    };
    secrets.user-password = {
      neededForUsers = true; # Wichtig, wenn es für den Login-User ist
    };
  };
  

  services.udisks2.enable = true; # for USB-Automount
#  systemd.user.services.udiskie = {
#    description = "udiskie automounter";
#    wantedBy = [ "graphical-session.target" ];
#    partOf = [ "graphical-session.target" ];
#    serviceConfig = {
#      ImportAware = true;
#      ExecStart = "${pkgs.udiskie}/bin/udiskie -f yazi";
#      Restart = "always" ;
#    };
#  };
  
  console.keyMap = "en";
  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };
  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-yubikey
    udiskie 
    xdg-utils
  ];
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    TERMINAL = "alacritty";
    XDG_TERMINA_EXEC = "alacritty";
  };
  xdg = {
    mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "yazi.desktop" ];
      };
    };
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common.default = [ "gtk" ];
        hyprland.default = [ "hyprland" ];
        noctalia.default = [ "wlr" ];
      };
    };
  };
  # Wichtig für Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  system.stateVersion = "24.05";
}

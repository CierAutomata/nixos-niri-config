{ config, pkgs, lib, ... }:

lib.mkIf (config.myConfig.wm == "hyprland") {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Enable SDDM
  services.displayManager.sddm = {
    enable = true;
    # Optional: Enable Wayland support in SDDM
    wayland = {
      enable = false;
    };
    #theme = "breeze"; # Optional: Set SDDM theme
  };
  services.xserver.enable = true;
  environment.systemPackages = with pkgs; [
    waybar
    hyprpaper
    hyprlock
    rofi
  ];

  xdg.portal = {
    enable = true;
    #extraPortals = [
      #pkgs.xdg-desktop-portal-hyprland
      #pkgs.xdg-desktop-portal-wlr
      #pkgs.xdg-desktop-portal-gtk
    #];
    #config = {
    #  common.default = [ "gtk" ];
    #  hyprland.default = [ "hyprland" ];
    #  noctalia.default = [ "wlr" ];
    #};
  };
  security.polkit.enable = true;

  environment.variables ={
    QT_QPA_PLATFORMTHEME = "gtk3";
  };
}

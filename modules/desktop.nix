{ inputs, pkgs, ... }:

{
  programs.niri.enable = true;

  environment.systemPackages = [
    pkgs.discord
    pkgs.noctalia-shell
    pkgs.wayland-utils
    pkgs.xwayland-satellite # Falls du X11 Apps in Niri brauchst
  ];

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;  

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };
}

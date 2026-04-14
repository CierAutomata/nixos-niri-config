{ inputs, pkgs, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = inputs.niri.packages.${pkgs.system}.niri;

  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.system}.default
    pkgs.discord
    pkgs.wayland-utils
    pkgs.xwayland-satellite # Falls du X11 Apps in Niri brauchst
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "gnome";
  };
}
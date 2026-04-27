{ config, pkgs, lib, ... }:

lib.mkIf (config.myConfig.wm == "niri") {
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # niri-session exportiert WAYLAND_DISPLAY in die systemd-Umgebung
  # und aktiviert graphical-session.target — notwendig für UWSM
  programs.uwsm.waylandCompositors.niri = {
    prettyName = "Niri";
    comment = "Niri Wayland Compositor";
    binPath = "${pkgs.niri}/bin/niri-session";
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
  };
  services.xserver.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Chromium/Electron-Apps nativ auf Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  environment.systemPackages = with pkgs; [
    playerctl
    xwayland-satellite
  ];

  systemd.user.services.xwayland-satellite = {
    description = "Xwayland Satellite";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment DISPLAY=:0";
      Restart = "on-failure";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome  # Screensharing / Screencasting
      pkgs.xdg-desktop-portal-gtk    # Dateidialoge / Fallback
    ];
    config.common.default = [ "gnome" "gtk" ];
  };
}

{ config, pkgs, lib, ... }:

lib.mkIf (config.myConfig.wm == "niri") {
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Registriert niri-uwsm.desktop — ohne diesen Eintrag findet uwsm den Compositor nicht.
  programs.uwsm.waylandCompositors.niri = {
    prettyName = "Niri";
    comment = "Niri Wayland Compositor";
    binPath = "${pkgs.niri}/bin/niri";
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start niri-uwsm.desktop'";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Chromium/Electron-Apps (Firefox, Discord, VS Code) nativ auf Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    waybar
    swaylock
    swayidle
    rofi
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome  # Screensharing / Screencasting
      pkgs.xdg-desktop-portal-gtk    # Dateidialoge / Fallback
    ];
    config.common.default = [ "gnome" "gtk" ];
  };
}

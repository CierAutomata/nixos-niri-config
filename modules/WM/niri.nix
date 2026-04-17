{ config, pkgs, lib, ... }:

lib.mkIf (config.myConfig.wm == "niri") {
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start niri'";
      user = config.myConfig.userName;
    };
  };

  environment.systemPackages = with pkgs; [
    waybar
    swaylock
    swayidle
    rofi-wayland
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "wlr" ];
      noctalia.default = [ "wlr" ];
    };
  };
}

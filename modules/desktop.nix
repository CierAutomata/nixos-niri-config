{ config, pkgs, lib, ... }:

{
  # UWSM nur wenn ein WM aktiv ist
  programs.uwsm.enable = config.myConfig.wm != "none";

  # Systemweite Grundpakete für Desktop-Nutzung
  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    yazi
  ] ++ config.myConfig.extraSystemPackages;

  hardware.bluetooth.enable = true;
  services.upower.enable = true;
}

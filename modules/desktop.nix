{ config, pkgs, lib, ... }:

{
  programs.uwsm.enable = config.myConfig.wm != "none";

  # Systemweite Grundpakete für Desktop-Nutzung
  environment.systemPackages = with pkgs; [
    #greetd.tuigreet
    #yazi
    #udiskie
    #xdg-utils
    #nautilus
  ] ++ config.myConfig.extraSystemPackages;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
    };
  };
  services.upower.enable = true;
}

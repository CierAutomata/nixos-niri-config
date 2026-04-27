{ config, pkgs, lib, ... }:

{
  programs.uwsm.enable = config.myConfig.wm != "none";

  systemd.user.services.polkit-agent = lib.mkIf (config.myConfig.wm != "none") {
    description = "Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  environment.systemPackages = config.myConfig.extraSystemPackages;
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

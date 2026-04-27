{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.myConfig.gaming {
    programs.java.enable = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraPackages = [ pkgs.jdk ];
      gamescopeSession.enable = true;
    };
  };
}

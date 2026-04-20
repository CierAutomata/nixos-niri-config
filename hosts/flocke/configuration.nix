{ config, pkgs, lib,  ... }:

{
  imports = [ ./hardware-conf.nix ];

  myConfig = {
    wm = "niri";
    isLaptop = true;
    userName = "cier";
    # configDir = "/home/cier/nixos-config"; # Standard, nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "flocke";

  users.users.cier = {
    isNormalUser = true;
    description = "CierAutomata";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
    hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root-password.path;
  };

  users.mutableUsers = false;
  system.stateVersion = "26.05";
}

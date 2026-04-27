{ config, pkgs, lib,  ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./hardware.nix 
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  myConfig = {
    wm = "hyprland";
    isLaptop = true;
    userName = "cier";
    sddmTheme = "default";
    keyboard = "us";
    # configDir = "/home/cier/nixos-config"; # Standard, nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "flocke";

  users.users.cier = {
    isNormalUser = true;
    description = "CierAutomata";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
    #hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  #users.users.root = {
  #  hashedPasswordFile = config.sops.secrets.root-password.path;
  #};

  #users.mutableUsers = false;
  system.stateVersion = "26.05";
  hardware.bluetooth.enable = true;

}

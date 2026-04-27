{ config, pkgs, lib,  ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./hardware.nix
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  myConfig = {
    wm = "hyprland";
    isLaptop = false;
    userName = "cier";
    sddmTheme = "rei";
    keyboard = "de";
    gaming = true;
    # configDir = "/home/cier/nixos-config"; # Standard, nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "milky";

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

}

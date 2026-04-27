{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./hardware.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  myConfig = {
    wm = "hyprland";        # "hyprland" | "niri" | "none"
    isLaptop = false;
    userName = "cier";
    sddmTheme = "default";  # "default" | "rei"
    keyboard = "us";        # "us" | "de"
    # gaming = true;
    # configDir = "/home/cier/nixos-config";
  };

  networking.hostName = "HOSTNAME";

  users.users.cier = {
    isNormalUser = true;
    description = "CierAutomata";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
    # hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  # users.mutableUsers = false;
  system.stateVersion = "26.05";
  # hardware.bluetooth.enable = true;
}

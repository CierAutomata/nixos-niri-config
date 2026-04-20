{ config, pkgs, lib, ... }:

{
  # hardware-conf.nix wird von bootstrap.sh generiert (gitignored).
  # Sie kombiniert hardware-nixos.nix (NixOS auto-generated) + hardware-gen.nix (persistent).
  imports = [ ./hardware-conf.nix ];

  myConfig = {
    wm = "niri";
    isLaptop = false;
    userName = "briest";
    # configDir = "/home/briest/nixos-config"; # Standard — nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "itpc-eibt014339";

  users.users.briest = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
  };

  users.mutableUsers = true;
  system.stateVersion = "26.05";
}

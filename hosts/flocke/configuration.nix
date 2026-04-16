{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/boot.nix
    ../../modules/nix-setup.nix
    ../../modules/core.nix
    ../../modules/tools.nix
    ../../modules/desktop.nix
    ../../modules/sops.nix
  ];

  networking.hostName = "flocke";

  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" "disk" "storage" ];
    hashedPasswordFile = config.sops.secrets.users.cier.hashedPassword.path;
  };

  users.mutableUsers = true;

  system.stateVersion = "26.05";
}

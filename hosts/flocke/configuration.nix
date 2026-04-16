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
    hashedPasswordFile = if config.sops ? secrets &&
      config.sops.secrets ? users &&
      config.sops.secrets.users ? cier &&
      config.sops.secrets.users.cier ? hashedPassword
    then config.sops.secrets.users.cier.hashedPassword.path
    else null;
  };

  users.mutableUsers = false;

  system.stateVersion = "26.05";
}

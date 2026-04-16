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
    # hashedPasswordFile is disabled while secrets/secrets.yaml is being rotated
    # and the correct private age key is not yet available. Re-enable when
    # `secrets/secrets.yaml` can be decrypted reliably.
    # hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  users.mutableUsers = false;

  system.stateVersion = "24.05";
}

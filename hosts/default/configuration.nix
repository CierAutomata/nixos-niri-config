{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
  ];

  users.users.briest = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # Wichtig für Fonts
  fonts.packages = with pkgs; [
    nerdfonts
  ];

  system.stateVersion = "24.05";
}
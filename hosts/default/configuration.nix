{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/core.nix
    ../../modules/desktop.nix
  ];
  networking.hostName = "flocke";

  
  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };
  
  console.keyMap = "en";
  services.xserver.xkb.layout = "en";
  
  # Wichtig für Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  system.stateVersion = "24.05";
}

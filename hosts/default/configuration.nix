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
  
  console.keyMap = "de";
  services.xserver.xkb.layout = "de";
  
  # Wichtig für Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  system.stateVersion = "24.05";
}

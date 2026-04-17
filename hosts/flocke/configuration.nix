{ ... }:

{
  imports = [ ./hardware-conf.nix ];

  myConfig = {
    wm = "hyprland";
    isLaptop = true;
    userName = "cier";
    # configDir = "/home/cier/nixos-config"; # Standard, nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "flocke";

  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
  };

  users.mutableUsers = true;
  system.stateVersion = "26.05";
}

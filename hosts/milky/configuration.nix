{ config, pkgs, lib,  ... }:

{
  imports = [ 
    /etc/nixos/hardware-configuration.nix
    ./hardware.nix
    ];

  nixpkgs.hostPlatform = "x86_64-linux";

  myConfig = {
    wm = "niri";
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
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" "libvirtd" ];
    #hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  #users.users.root = {
  #  hashedPasswordFile = config.sops.secrets.root-password.path;
  #};
  
  environment.systemPackages = with pkgs; [

    qemu
    OVMF
    virt-viewer
    passt
    looking-glass-client
    virt-manager
  ];

  # OVMF an stabilen Pfaden bereitstellen (NixOS-Store-Pfad wechselt bei Updates)
  environment.etc = {
    "ovmf/OVMF_CODE.fd".source = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd";
    "ovmf/OVMF_VARS.fd".source = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
  };

  virtualisation.libvirtd.enable = true;

  #users.mutableUsers = false;
  system.stateVersion = "26.05";

}

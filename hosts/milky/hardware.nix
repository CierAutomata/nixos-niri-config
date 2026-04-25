{ config, lib, pkgs, modulesPath, ...  }:
{
  
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  fileSystems."/home/cier/games" = {
    device = "/dev/disk/by-uuid/6985268c-81e1-4289-baf7-7e8794b63077";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}

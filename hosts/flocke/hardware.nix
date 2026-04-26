{ config, lib, pkgs, modulesPath, ...  }:
{
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/flocke-data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}

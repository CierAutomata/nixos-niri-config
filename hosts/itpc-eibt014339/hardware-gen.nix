# Persistente Hardware-Konfiguration — wird committet und bleibt über Neu-Installationen erhalten.
# Hier kommen Dinge rein die nixos-generate-config NICHT erkennt:
#   - Persistente Datenmounts (externe Festplatten, NAS, etc.)
#   - Zusätzliche Swap-Partitionen
#   - Hardware-spezifische Kernel-Parameter
{ config, lib, pkgs, modulesPath, ... }:

{
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}

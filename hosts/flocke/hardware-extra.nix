# Persistente Hardware-Konfiguration für flocke.
# Wird committet und bleibt über Neuinstallationen erhalten.
#
# Hier kommen Dinge rein, die nixos-generate-config NICHT automatisch erkennt:
#   - Persistente Datenmounts (externe Festplatten, NAS, etc.)
#   - Zusätzliche Swap-Partitionen
#   - Hardware-spezifische Kernel-Parameter
{ config, lib, pkgs, modulesPath, ... }:

{
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/flocke-data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}

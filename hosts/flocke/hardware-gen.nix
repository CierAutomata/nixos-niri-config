# Persistente Hardware-Konfiguration für flocke.
# Diese Datei wird committet und bleibt über Neu-Installationen hinweg erhalten.
#
# Hier kommen Dinge rein, die nixos-generate-config NICHT automatisch erkennt
# oder die nach einer Neu-Installation nicht verloren gehen dürfen:
#   - Persistente Datenmounts (externe Festplatten, NAS, etc.)
#   - Zusätzliche Swap-Partitionen
#   - Hardware-spezifische Kernel-Parameter
#
# Die auto-generierte NixOS hardware-configuration landet in hardware-nixos.nix
# (gitignored). Beide werden von hardware-conf.nix (gitignored) zusammengeführt.
{ config, lib, pkgs, modulesPath, ... }:

{
  # Beispiel: persistenter Daten-Mount der nach Neuinstallation erhalten bleibt
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/flocke-data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}

# Kombiniert die dynamische NixOS hardware-configuration mit der persistenten hardware-gen.
# Automatisch generiert von bootstrap.sh — nicht manuell bearbeiten.
{ ... }:
{
  imports = [
    ./hardware-nixos.nix  # Placeholder committed; bootstrap.sh überschreibt mit echter Config
    ./hardware-gen.nix    # Committed — persistente Mounts, custom Hardware
  ];
}

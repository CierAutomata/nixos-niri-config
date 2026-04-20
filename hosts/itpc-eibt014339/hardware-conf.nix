# Kombiniert die dynamische NixOS hardware-configuration mit der persistenten hardware-gen.
# Automatisch generiert von bootstrap.sh — nicht manuell bearbeiten.
{ ... }:
{
  imports = [
    ./hardware-nixos.nix
    ./hardware-gen.nix
  ];
}

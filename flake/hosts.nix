{ inputs, lib, ... }:

# Flake-parts module: baut nixosConfigurations für jeden Host in ./hosts/
# Alle shared Module werden automatisch eingebunden; Hosts setzen nur Optionen.
let
  sharedModules = [
    inputs.home-manager.nixosModules.home-manager
    #inputs.sops-nix.nixosModules.sops
    ../modules/options.nix
    ../modules/home-manager-setup.nix
    ../modules/boot.nix
    ../modules/nix-setup.nix
    ../modules/core.nix
    ../modules/tools.nix
    ../modules/desktop.nix
    ../modules/laptop.nix
    ../modules/wm/hyprland.nix
    ../modules/wm/niri.nix
    #../modules/sops.nix
    ../modules/silent-sddm.nix
  ];
in
{
  flake.nixosConfigurations =
    lib.genAttrs
      (builtins.attrNames (builtins.readDir ../hosts))
      (hostname: inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = sharedModules ++ [ ../hosts/${hostname}/configuration.nix ];
      });
}

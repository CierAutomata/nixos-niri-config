{ pkgs, inputs, ... }:
let
  rose-pine-grub = pkgs.stdenvNoCC.mkDerivation {
    name = "rose-pine-grub-theme";
    src = inputs.rose-pine-grub;
    installPhase = ''
      mkdir -p $out/grub/themes/rose-pine
      cp -r . $out/grub/themes/rose-pine
    '';
  };
in
{
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 10;
    theme = "${rose-pine-grub}/grub/themes/rose-pine";
  };
  boot.loader.efi.canTouchEfiVariables = true;
}

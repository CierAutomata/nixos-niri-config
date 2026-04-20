{ pkgs, ... }:
{
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-yubikey
    ssh-to-age
    udiskie
    xdg-utils
    nautilus
  ];

  console.keyMap = "en";
  services.xserver.xkb = {
    layout = "en";
    variant = "";
  };

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
    };
  };
}

{ config, lib, ... }:

{
  options.myConfig = {
    wm = lib.mkOption {
      type = lib.types.enum [ "niri" "hyprland" "none" ];
      default = "hyprland";
      description = "Window manager für diesen Host.";
    };

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Aktiviert laptop-spezifische Features (TLP, Backlight, Lid-Switch).";
    };

    userName = lib.mkOption {
      type = lib.types.str;
      default = "cier";
      description = "Primärer Nutzername auf diesem Host.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      description = "Absoluter Pfad zum nixos-config Repo auf der Disk (für Dotfile-Symlinks).";
    };

    sddmTheme = lib.mkOption {
      type = lib.types.str;
      default = "rei";
      description = "silentSDDM Theme für diesen Host.";
    };

    keyboard = lib.mkOption {
      type = lib.types.enum [ "de" "us" ];
      default = "us";
      description = "Tastaturlayout für diesen Host (console + xkb).";
    };

    gaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Aktiviert Steam, Gamescope und Gaming-Pakete.";
    };

    extraSystemPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Zusätzliche systemweite Pakete für diesen Host.";
    };
  };

  # configDir leitet sich standardmäßig vom userName ab
  config.myConfig.configDir = lib.mkDefault "/home/${config.myConfig.userName}/nixos-config";
}

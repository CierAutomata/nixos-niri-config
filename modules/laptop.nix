{ config, pkgs, lib, ... }:

lib.mkIf config.myConfig.isLaptop {
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}="80"
  '';
  users.users.${config.myConfig.userName}.extraGroups = [ "video" ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
  };

  services.upower.enable = lib.mkForce true;
}

{ inputs, pkgs, ... }:

{
  # Hyprland aktivieren
  programs.hyprland = {
  enable = true;
  xwayland.enable = true;
  withUWSM = true; 
  };
  # Greetd Login-Manager (angepasst auf Hyprland)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "cier";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    noctalia-shell
    discord
    alacritty
    greetd.tuigreet
    # Nützliche Tools für Hyprland
    waybar       # Falls Noctalia mal nicht reicht
    hyprpaper    # Wallpaper
    hyprlock     # Lockscreen
    firefox
    rofi
    brave
    code
  ];

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.upower.enable = true;  

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}

{ config, pkgs, lib, ... }:

{
  networking.networkmanager.enable = true;

#  services.openssh = {
#    enable = true;
#    settings = {
#      PasswordAuthentication = false;
#      PermitRootLogin = "no";
#    };
#    hostKeys = [
#      { type = "ed25519"; path = "/etc/ssh/ssh_host_ed25519_key"; }
#    ];
#  };

  services.pcscd.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];
  programs.fish.enable = true;
  programs.bash = {
  interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
  };
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    TERMINAL = "alacritty";
    XDG_TERMINAL_EXEC = "alacritty";
  };

  console.keyMap = config.myConfig.keyboard;
  services.xserver.xkb = {
    layout = config.myConfig.keyboard;
    variant = "";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}

{ config, pkgs, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      sshKeyPaths = [];
      keyFile = "/home/${config.myConfig.userName}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    secrets.user-password = {
      key = "users/${config.myConfig.userName}/hashedPassword";
      neededForUsers = true;
    };

    secrets.root-password = {
      key = "users/root/hashedPassword";
      neededForUsers = true;
    };
  };

  # pcscd während der Aktivierung starten damit age-plugin-yubikey
  # den YubiKey für die Entschlüsselung nutzen kann (falls eingesteckt).
  # Läuft alphabetisch vor setupSecrets / setupSecretsForUsers.
  system.activationScripts.setupYubikeyForSopsNix = {
    text = ''
      PATH=$PATH:${lib.makeBinPath [ pkgs.age-plugin-yubikey ]}
      mkdir -p /var/lib/pcsc
      ln -sfn ${pkgs.ccid}/pcsc/drivers /var/lib/pcsc/drivers
      ${pkgs.procps}/bin/pkill pcscd 2>/dev/null || true
      ${pkgs.pcsclite}/bin/pcscd
    '';
  };
  system.activationScripts.setupSecrets.deps        = [ "setupYubikeyForSopsNix" ];
  system.activationScripts.setupSecretsForUsers.deps = [ "setupYubikeyForSopsNix" ];
}

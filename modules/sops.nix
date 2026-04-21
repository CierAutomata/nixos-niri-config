{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      # Primär: SSH-Host-Key (von bootstrap.sh als SOPS-Empfänger registriert)
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      # Fallback: alter Key-File (Übergangslösung, kann entfernt werden sobald SSH-Key aktiv ist)
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
}

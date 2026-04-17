{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/${config.myConfig.userName}/.config/sops/age/keys.txt";
      generateKey = false;
    };

    # Passwort-Secret aktivieren sobald hashedPassword in secrets.yaml gepflegt ist:
    #secrets.user-password = {
    #  neededForUsers = true;
    #};
  };
}

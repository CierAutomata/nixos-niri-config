{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/${config.myConfig.userName}/.config/sops/age/keys.txt";
      generateKey = false;
    };

#    secrets.user-password = {
#      key = "users/${config.myConfig.userName}/hashedPassword";
#      neededForUsers = true;
#    };

    secrets.root-password = {
      key = "users/root/hashedPassword";
      neededForUsers = true;
    };
  };
}

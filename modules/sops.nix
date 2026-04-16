{ config, lib, ... }:
let
  # Path where the private age key is expected during activation
  keyPath = "/home/cier/.config/sops/age/keys.txt";
  keyPresent = builtins.pathExists keyPath;
in
{
  # Only enable sops configuration if the private key is available on the system.
  # This prevents the activation-phase decryption from failing (which aborts
  # other activation snippets like creating user symlinks).
  sops = lib.mkIf keyPresent {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = keyPath;
      generateKey = false;
    };

    secrets.user-password = {
      neededForUsers = true;
    };
  };

  # If the key is not present, keep sops unset so activation continues.
}

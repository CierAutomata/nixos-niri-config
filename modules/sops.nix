{ config, lib, ... }:
let
  # Path where the private age key is expected during activation
  keyPath = "/home/cier/.config/sops/age/keys.txt";
  # Absolute path to secrets file
  secretsFile = ../secrets/secrets.yaml;
in
{
  # Enable sops configuration unconditionally. The build that evaluates the
  # flake must provide the private Age key at `keyPath` (see notes below).
  sops = {
    defaultSopsFile = secretsFile;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = keyPath;
      generateKey = false;
    };

    # sops-nix maps this flat secret name to `user-password` in secrets.yaml
    secrets.user-password = {
      neededForUsers = true;
    };
  };

  # Note: Make sure the private Age key exists at `keyPath` on the machine
  # where you run `nixos-rebuild`/`nixos-install` so sops can decrypt secrets
  # during evaluation.
}

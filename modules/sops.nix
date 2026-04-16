{ config, lib, ... }:
let
  # Path where the private age key is expected during activation
  keyPath = "/home/cier/.config/sops/age/keys.txt";
in
{
  # Enable sops configuration unconditionally. The build that evaluates the
  # flake must provide the private Age key at `keyPath` (see notes below).
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = keyPath;
      generateKey = false;
    };

    # Backwards-compatible mapping: some hosts expect the older
    # `secrets.user-password` key. Keep it for compatibility.
    #secrets.user-password = {
    #  neededForUsers = true;
    #};

    # Expose the nested `users.cier.hashedPassword` key from
    # secrets/secrets.yaml so the host config can reference it directly.
    secrets.users = {
      cier = {
        hashedPassword = {
          neededForUsers = true;
        };
      };
    };
  };

  # Note: Make sure the private Age key exists at `keyPath` on the machine
  # where you run `nixos-rebuild`/`nixos-install` so sops can decrypt secrets
  # during evaluation.
}

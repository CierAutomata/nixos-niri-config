# One-Line-Install
`nix-shell -p git --run "git clone https://github.com/CierAutomata/nixos-config ~/nixos-config && nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/flocke/hardware-gen.nix && sudo nixos-rebuild switch --flake ~/nixos-config#flocke"`

Mit dem Bootstrap-Skript kannst du später mehrere Hosts verwalten:

- `./bootstrap.sh`  # interaktive Auswahl
- `./bootstrap.sh flocke`
- `./bootstrap.sh milky`
- `./bootstrap.sh milky /run/media/cier/9CF8-165B/key.txt`
# nixos-config

Meine persönliche NixOS-Konfiguration als Flake — verwaltet mehrere Maschinen mit gemeinsamen Modulen und Host-spezifischen Einstellungen.

## Hosts

| Hostname | Typ | WM | User | Besonderheiten |
|---|---|---|---|---|
| `itnb-b2954j3` | Laptop | Hyprland | briest | libvirtd, QEMU/OVMF, looking-glass |
| `milky` | Desktop | Niri | cier | NVIDIA, Gaming (Steam/Gamescope), libvirtd |
| `template` | — | — | — | Kopiervorlage für neue Hosts |

## Installation (frisches NixOS-System)

```bash
# 1. Temporäre Shell mit git (Flakes/nix-command auf Minimal-ISO noch nicht aktiviert)
nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git --command bash

# 2. Repo klonen
git clone https://github.com/CierAutomata/nixos-config ~/nixos-config
cd ~/nixos-config

# 3. Aktivieren (hostname anpassen)
sudo nixos-rebuild switch --flake .#itnb-b2954j3 --impure
```

> `--impure` ist nötig, weil `/etc/nixos/hardware-configuration.nix` direkt eingebunden wird und nicht im Repo liegt.

## Rebuild-Befehle

```bash
# Sofort aktivieren
sudo nixos-rebuild switch --flake ~/nixos-config#$HOSTNAME --impure

# Beim nächsten Boot aktivieren
sudo nixos-rebuild boot --flake ~/nixos-config#$HOSTNAME --impure

# Testen ohne Aktivierung
sudo nixos-rebuild test --flake ~/nixos-config#$HOSTNAME --impure

# Flake-Syntax prüfen
nix flake check

# Inputs aktualisieren
nix flake update
```

## Struktur

```
nixos-config/
├── flake.nix              # Flake-Einstiegspunkt
├── flake/
│   └── hosts.nix          # Auto-generiert nixosConfigurations aus hosts/
├── hosts/
│   ├── itnb-b2954j3/      # Laptop-Konfiguration
│   ├── milky/             # Desktop-Konfiguration
│   └── template/          # Vorlage für neue Hosts
├── modules/               # Gemeinsame Module (core, desktop, home, sops, …)
│   └── wm/                # Compositor-Module (hyprland.nix, niri.nix)
├── dotfiles/              # Live-Symlinks nach ~/.config/
├── packages/              # Selbst gepflegte Nix-Derivationen
│   └── vm-curator/        # TUI-VM-Manager (gepatcht für NixOS)
└── standalone/
    └── fedora/            # home-manager für Nicht-NixOS-Systeme
```

### Dotfiles

`dotfiles/` wird per `mkOutOfStoreSymlink` live in `~/.config/` verlinkt — Änderungen greifen sofort ohne Rebuild. Host-spezifische Overrides liegen unter `dotfiles/<app>/hosts/<hostname>.*`.

### Neuen Host hinzufügen

Ein neues Verzeichnis unter `hosts/<hostname>/` anlegen (z. B. von `template` kopieren) — `flake/hosts.nix` registriert ihn automatisch. Dann `hosts/<hostname>/configuration.nix` und `hardware.nix` anpassen.

### Standalone (Nicht-NixOS)

`standalone/fedora/` enthält eine home-manager-Konfiguration für Fedora (User `briest`) mit Dotfile-Symlinks, yazi, kitty und git-Konfiguration.

#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_HOST="flocke"

usage() {
  cat <<EOF
Usage: $0 [HOST] [AGE_KEY_SOURCE]

Automatisiert die Schritte nach einer frischen NixOS-Installation.

HOST            optionaler Hostname, z. B. flocke oder milky.
AGE_KEY_SOURCE  optionaler Pfad zur privaten age-Key-Datei. Wenn kein Pfad
               angegeben ist, sucht das Skript automatisch nach einer
               key.txt oder keys.txt auf typischen USB-Mount-Pfaden.
EOF
  exit 1
}

HOST_NAME="$DEFAULT_HOST"
KEY_SOURCE=""

find_key_file() {
  local paths=(/run/media/"$USER" /run/media /media/"$USER" /media /mnt)
  local files=()

  for base in "${paths[@]}"; do
    if [ -d "$base" ]; then
      while IFS= read -r -d '' file; do
        files+=("$file")
      done < <(find "$base" -maxdepth 3 -type f \( -name 'key.txt' -o -name 'keys.txt' \) -print0 2>/dev/null)
    fi
  done

  case "${#files[@]}" in
    0)
      return 2
      ;;
    1)
      printf '%s' "${files[0]}"
      ;;
    *)
      echo "Mehrere key/keyS.txt-Dateien gefunden:" >&2
      local idx=1
      for file in "${files[@]}"; do
        echo "  $idx) $file" >&2
        idx=$((idx + 1))
      done
      while true; do
        read -rp "Wähle die richtige key-Datei [1-$((idx - 1))]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$idx" ]; then
          printf '%s' "${files[$((choice - 1))]}"
          return 0
        fi
        echo "Ungültige Auswahl."
      done
      ;;
  esac
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
fi

if [ ! -f "$REPO_ROOT/flake.nix" ]; then
  echo "Error: Dieses Skript muss im Repo-Root ausgeführt werden." >&2
  exit 1
fi

if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix ist nicht installiert. Bitte installiere Nix zuerst." >&2
  exit 1
fi

list_hosts() {
  local hostdir="$REPO_ROOT/hosts"
  local host
  local hosts=()

  for host in "$hostdir"/*; do
    if [ -d "$host" ]; then
      hosts+=("$(basename "$host")")
    fi
  done

  printf '%s
' "${hosts[@]}"
}

select_host() {
  mapfile -t hosts < <(list_hosts)

  if [ "${#hosts[@]}" -eq 0 ]; then
    echo "Keine Hosts in $REPO_ROOT/hosts gefunden. Erstelle einen neuen Host."
    read_new_host
    return
  fi

  echo "Welchen Host möchtest du installieren?"
  echo "1) Neuen Host anlegen"
  local i=2
  for host in "${hosts[@]}"; do
    echo "$i) $host"
    i=$((i + 1))
  done
  echo "0) Abbrechen"

  while true; do
    read -rp "Auswahl [0-$((i - 1))]: " choice
    case "$choice" in
      0)
        echo "Abgebrochen."
        exit 1
        ;;
      1)
        read_new_host
        return
        ;;
      ''|*[!0-9]*)
        echo "Bitte eine Zahl eingeben."
        ;;
      *)
        if [ "$choice" -ge 2 ] 2>/dev/null && [ "$choice" -lt "$i" ]; then
          HOST_NAME="${hosts[$((choice - 2))]}"
          return
        fi
        echo "Ungültige Auswahl."
        ;;
    esac
  done
}

read_new_host() {
  while true; do
    read -rp "Name des neuen Hosts: " host
    if [ -z "$host" ]; then
      echo "Bitte einen Hostnamen eingeben."
      continue
    fi
    if [ -d "$REPO_ROOT/hosts/$host" ]; then
      echo "Host '$host' existiert bereits."
      continue
    fi
    HOST_NAME="$host"
    create_host_skeleton "$HOST_NAME"
    return
  done
}

case "$#" in
0)
  select_host
  ;;
1)
  if [ -f "$1" ] || [[ "$1" == */* ]] || [[ "$1" == .* ]] || [[ "$1" == ~* ]] || [[ "$1" == *key.txt ]] || [[ "$1" == *keys.txt ]]; then
    KEY_SOURCE="$1"
  else
    HOST_NAME="$1"
    if [ ! -d "$REPO_ROOT/hosts/$HOST_NAME" ]; then
      read -rp "Host '$HOST_NAME' existiert nicht. Neuen Host anlegen? [y/N] " create_confirm
      case "$create_confirm" in
        [yY]|[yY][eE][sS])
          create_host_skeleton "$HOST_NAME"
          ;;
        *)
          echo "Abgebrochen." >&2
          exit 1
          ;;
      esac
    fi
  fi
  ;;
2)
  HOST_NAME="$1"
  KEY_SOURCE="$2"
  if [ ! -d "$REPO_ROOT/hosts/$HOST_NAME" ]; then
    read -rp "Host '$HOST_NAME' existiert nicht. Neuen Host anlegen? [y/N] " create_confirm
    case "$create_confirm" in
      [yY]|[yY][eE][sS])
        create_host_skeleton "$HOST_NAME"
        ;;
      *)
        echo "Abgebrochen." >&2
        exit 1
        ;;
    esac
  fi
  ;;
*)
  usage
  ;;
esac

create_host_skeleton() {
  local host="$1"
  local dir="$REPO_ROOT/hosts/$host"

  mkdir -p "$dir"
  if [ ! -f "$dir/configuration.nix" ]; then
    cat >"$dir/configuration.nix" <<EOF
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-gen.nix
    ../../modules/boot.nix
    ../../modules/nix-setup.nix
    ../../modules/core.nix
    ../../modules/tools.nix
    ../../modules/desktop.nix
    ../../modules/sops.nix
  ];

  networking.hostName = "$host";

  users.users.cier = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "video" "disk" "storage" ];
    hashedPasswordFile = config.sops.secrets.user-password.path;
  };

  users.mutableUsers = false;

  system.stateVersion = "24.05";
}
EOF
    echo "Neues Host-Template erstellt: $dir/configuration.nix"
  fi
}

HOST_DIR="$REPO_ROOT/hosts/$HOST_NAME"
create_host_skeleton "$HOST_NAME"
HARDWARE_GEN="$HOST_DIR/hardware-gen.nix"

if [ -f /etc/nixos/hardware-configuration.nix ]; then
  echo "Kopiere /etc/nixos/hardware-configuration.nix nach $HARDWARE_GEN"
  sudo cp /etc/nixos/hardware-configuration.nix "$HARDWARE_GEN"
else
  echo "Warnung: /etc/nixos/hardware-configuration.nix existiert nicht." >&2
fi

if [ -z "$KEY_SOURCE" ]; then
  echo "Suche automatisch nach key.txt oder keys.txt auf typischen USB-Mounts..."
  if KEY_SOURCE="$(find_key_file)"; then
    echo "Gefunden: $KEY_SOURCE"
  else
    if [ $? -eq 1 ]; then
      echo "Error: Mehrere key/keyS.txt-Dateien gefunden. Bitte gib den gewünschten Pfad als Argument an." >&2
      exit 1
    fi
    echo "Warnung: Konnte keine key.txt oder keys.txt automatisch finden." >&2
  fi
fi

if [ -n "$KEY_SOURCE" ]; then
  if [ ! -f "$KEY_SOURCE" ]; then
    echo "Error: Die angegebene Datei existiert nicht: $KEY_SOURCE" >&2
    exit 1
  fi
  mkdir -p "$HOME/.config/sops/age"
  echo "Kopiere private age-Key-Datei nach ~/.config/sops/age/keys.txt"
  cp "$KEY_SOURCE" "$HOME/.config/sops/age/keys.txt"
fi

if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
  echo "Warnung: ~/.config/sops/age/keys.txt existiert nicht." >&2
  echo "Bitte privaten age-Schlüssel hier ablegen: ~/.config/sops/age/keys.txt" >&2
fi

echo "Bitte kontrolliere in /etc/nixos/configuration.nix, dass folgende Zeile gesetzt ist:"
echo "  nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"

echo "Starte nixos-rebuild..."
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake "$REPO_ROOT#${HOST_NAME}"

echo "Fertig. Wenn der Rebuild erfolgreich war, kannst du das Skript künftig ohne NIX_CONFIG ausführen, sobald flakes dauerhaft aktiviert sind."
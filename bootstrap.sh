#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# ── Validierung ───────────────────────────────────────────────────────────────

usage() {
  cat <<EOF
Verwendung: $0 [HOST] [ALTER_AGE_KEY]

Automatisiert die Einrichtung nach einer frischen NixOS-Installation.

HOST            Optionaler Hostname (z. B. flocke, milky).
                Ohne Argument: interaktive Auswahl.
ALTER_AGE_KEY   Optionaler Pfad zum alten privaten age-Key (Übergangslösung).
                Ohne Angabe wird automatisch auf typischen USB-Pfaden gesucht.
                Wird nur für 'sops updatekeys' benötigt, falls noch kein
                YubiKey in .sops.yaml eingetragen ist.

Schlüssel-Strategie:
  Primär:     YubiKey via age-plugin-yubikey (manuell in .sops.yaml eintragen)
  Sekundär:   SSH-Host-Key (automatisch von diesem Skript registriert)
  Übergang:   Alter age-Key aus Datei (nur bis YubiKey eingerichtet)

Beispiele:
  ./bootstrap.sh
  ./bootstrap.sh flocke
  ./bootstrap.sh milky /run/media/cier/USB/keys.txt
EOF
  exit 0
}

[ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ] && usage

if [ ! -f "$REPO_ROOT/flake.nix" ]; then
  echo "Fehler: Skript muss im Repo-Root ausgeführt werden." >&2; exit 1
fi
if ! command -v nix >/dev/null 2>&1; then
  echo "Fehler: nix ist nicht installiert." >&2; exit 1
fi

# ── Tool-Bootstrap via nix shell ──────────────────────────────────────────────
# Vor dem ersten NixOS-Rebuild sind sops, age-plugin-yubikey und ssh-to-age
# noch nicht installiert. Falls sie fehlen, re-executed sich das Skript selbst
# in einem temporären nix shell mit allen nötigen Tools.
_TOOLS_MISSING=false
for _tool in sops age-plugin-yubikey ssh-to-age; do
  command -v "$_tool" >/dev/null 2>&1 || _TOOLS_MISSING=true
done

if [ "$_TOOLS_MISSING" = true ]; then
  echo "Benötigte Tools nicht gefunden — lade via nix shell (einmalig)..."
  exec nix --extra-experimental-features 'nix-command flakes' \
    shell \
    nixpkgs#sops \
    nixpkgs#age \
    nixpkgs#age-plugin-yubikey \
    nixpkgs#ssh-to-age \
    nixpkgs#pcsclite \
    nixpkgs#ccid \
    nixpkgs#yubikey-manager \
    --command bash "$0" "$@"
fi

# ── pcscd-Cleanup bei Skriptende ──────────────────────────────────────────────
_PCSCD_STARTED_BY_BOOTSTRAP=false
cleanup() {
  [ "$_PCSCD_STARTED_BY_BOOTSTRAP" = true ] && pkill pcscd 2>/dev/null || true
}
trap cleanup EXIT

# ── Hilfsfunktionen ───────────────────────────────────────────────────────────

# Sucht key.txt / keys.txt auf USB-Mounts und gibt den Pfad aus (leer = nicht gefunden).
find_key_file() {
  local paths=(/run/media/"$USER" /run/media /media/"$USER" /media /mnt)
  local files=()

  for base in "${paths[@]}"; do
    [ -d "$base" ] || continue
    while IFS= read -r -d '' file; do
      files+=("$file")
    done < <(find "$base" -maxdepth 3 -type f \( -name 'key.txt' -o -name 'keys.txt' \) -print0 2>/dev/null)
  done

  case "${#files[@]}" in
    0) return 0 ;;
    1) printf '%s' "${files[0]}" ;;
    *)
      echo "Mehrere Key-Dateien gefunden:" >&2
      local i=1
      for f in "${files[@]}"; do echo "  $i) $f" >&2; i=$((i+1)); done
      while true; do
        read -rp "Wähle die richtige Datei [1-$((i-1))]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
          printf '%s' "${files[$((choice-1))]}"; return 0
        fi
        echo "Ungültige Auswahl." >&2
      done ;;
  esac
}

# Hängt einen age-Public-Key an den age-Block in .sops.yaml an.
# Erwartet: $1 = age-Public-Key, $2 = Kommentar (z. B. "flocke-ssh")
append_age_key_to_sops() {
  local key="$1"
  local comment="$2"
  local sops_yaml="$REPO_ROOT/.sops.yaml"
  local new_line="        - ${key}  # ${comment}"

  awk -v line="$new_line" '
  {
    buf[NR] = $0
    if ($0 ~ /^[[:space:]]{8}- age/) last = NR
  }
  END {
    for (i = 1; i <= NR; i++) {
      print buf[i]
      if (i == last) print line
    }
  }
  ' "$sops_yaml" > "${sops_yaml}.tmp" && mv "${sops_yaml}.tmp" "$sops_yaml"
}

# Startet pcscd falls noch nicht laufend — benötigt damit age-plugin-yubikey
# mit dem YubiKey kommunizieren kann.
start_pcscd_if_needed() {
  pgrep -x pcscd > /dev/null 2>&1 && return 0

  echo "Starte pcscd für YubiKey-Kommunikation..."

  # ccid-Treiber verknüpfen damit pcscd den YubiKey erkennt
  local ccid_store
  ccid_store=$(nix --extra-experimental-features 'nix-command flakes' \
    path-info 'nixpkgs#ccid' 2>/dev/null) || ccid_store=""
  if [ -n "$ccid_store" ] && [ -d "$ccid_store/pcsc/drivers" ]; then
    mkdir -p /var/lib/pcsc
    ln -sfn "$ccid_store/pcsc/drivers" /var/lib/pcsc/drivers
  fi

  pcscd 2>/dev/null || sudo pcscd 2>/dev/null || {
    echo "Warnung: pcscd konnte nicht gestartet werden — YubiKey-Setup übersprungen." >&2
    return 1
  }
  sleep 1
  _PCSCD_STARTED_BY_BOOTSTRAP=true
  echo "✓ pcscd gestartet."
}

# Erkennt YubiKey, generiert Identity-Datei, trägt Empfänger in .sops.yaml ein.
# Gibt 0 zurück wenn ein Key neu hinzugefügt wurde, 1 sonst.
detect_and_add_yubikey() {
  local sops_yaml="$REPO_ROOT/.sops.yaml"

  command -v age-plugin-yubikey >/dev/null 2>&1 || return 1

  start_pcscd_if_needed || return 1

  local yubikey_recipient
  yubikey_recipient=$(age-plugin-yubikey --list 2>/dev/null | grep -E '^age1yubikey1' | head -1)

  if [ -z "$yubikey_recipient" ]; then
    echo "Kein age-Schlüssel auf YubiKey gefunden."
    read -rp "YubiKey jetzt einrichten? (interaktiver Assistent) [y/N]: " yn
    case "${yn:-N}" in
      [yY]|[yY][eE][sS])
        echo "Hinweis: Falls der Assistent fehlschlägt, ggf. zuerst ausführen:"
        echo "  ykman piv access change-management-key -a TDES --protect"
        age-plugin-yubikey
        yubikey_recipient=$(age-plugin-yubikey --list 2>/dev/null | grep -E '^age1yubikey1' | head -1)
        ;;
      *) return 1 ;;
    esac
  fi

  if [ -z "$yubikey_recipient" ]; then
    echo "Warnung: Kein YubiKey-Empfänger ermittelt." >&2
    return 1
  fi

  echo "YubiKey erkannt: $yubikey_recipient"

  # Identity-Datei für manuelle sops-Nutzung (~/.config/sops/age/keys.txt) speichern
  mkdir -p "$HOME/.config/sops/age"
  local keys_file="$HOME/.config/sops/age/keys.txt"
  if ! grep -qF 'AGE-PLUGIN-YUBIKEY' "$keys_file" 2>/dev/null; then
    age-plugin-yubikey --identity 2>/dev/null >> "$keys_file"
    echo "✓ YubiKey-Identity → ~/.config/sops/age/keys.txt gespeichert."
  else
    echo "✓ YubiKey-Identity bereits in keys.txt vorhanden."
  fi

  # Empfänger in .sops.yaml eintragen
  if grep -qF "$yubikey_recipient" "$sops_yaml"; then
    echo "✓ YubiKey bereits in .sops.yaml eingetragen."
    return 1
  fi

  echo "Trage YubiKey in .sops.yaml ein..."
  if grep -q '# - age1yubikey1EINTRAGEN' "$sops_yaml"; then
    sed -i "s|# - age1yubikey1EINTRAGEN|        - ${yubikey_recipient}  # yubikey|" "$sops_yaml"
  else
    append_age_key_to_sops "$yubikey_recipient" "yubikey"
  fi
  return 0
}

# Holt den SSH-Host-Ed25519-Key und registriert ihn als age-Empfänger in .sops.yaml.
# Gibt 0 zurück wenn ein Key hinzugefügt wurde, 1 sonst.
setup_ssh_age_key() {
  local host="$1"
  local ssh_pub="/etc/ssh/ssh_host_ed25519_key.pub"
  local sops_yaml="$REPO_ROOT/.sops.yaml"

  if [ ! -f "$ssh_pub" ]; then
    echo "Warnung: $ssh_pub nicht gefunden — SSH-Age-Key übersprungen." >&2
    return 1
  fi

  local age_pubkey
  age_pubkey=$(ssh-to-age < "$ssh_pub" 2>/dev/null)

  if [ -z "$age_pubkey" ]; then
    echo "Fehler: SSH-Key-Konvertierung fehlgeschlagen." >&2
    return 1
  fi

  if grep -qF "$age_pubkey" "$sops_yaml"; then
    echo "✓ SSH-Host-Key für '$host' bereits in .sops.yaml eingetragen."
    return 1
  fi

  echo "SSH-Host-Key ($host): $age_pubkey"
  echo "Trage SSH-Host-Key in .sops.yaml ein..."
  append_age_key_to_sops "$age_pubkey" "${host}-ssh"
  return 0
}

# Erstellt hosts/<host>/configuration.nix mit dem neuen myConfig-Format.
# Fragt WM, isLaptop und userName interaktiv ab.
create_host_skeleton() {
  local host="$1"
  local dir="$REPO_ROOT/hosts/$host"
  mkdir -p "$dir"

  if [ -f "$dir/configuration.nix" ]; then
    echo "Hinweis: $dir/configuration.nix existiert bereits, wird nicht überschrieben."
    return
  fi

  echo ""
  echo "=== Neuen Host '$host' konfigurieren ==="

  # Window Manager
  local wm
  echo ""
  echo "Window Manager:"
  echo "  1) hyprland (Standard)"
  echo "  2) niri"
  echo "  3) none  (Server / headless)"
  while true; do
    read -rp "Auswahl [1-3, Enter = 1]: " wm_choice
    case "${wm_choice:-1}" in
      1) wm="hyprland"; break ;;
      2) wm="niri";     break ;;
      3) wm="none";     break ;;
      *) echo "Bitte 1, 2 oder 3 eingeben." ;;
    esac
  done

  # Laptop?
  local is_laptop="false"
  read -rp "Ist '$host' ein Laptop? (TLP, Backlight, Lid-Switch) [y/N]: " laptop_choice
  case "${laptop_choice:-N}" in
    [yY]|[yY][eE][sS]) is_laptop="true" ;;
  esac

  # Username
  local user_name
  read -rp "Primärer Nutzername [cier]: " user_name
  user_name="${user_name:-cier}"

  cat >"$dir/configuration.nix" <<EOF
{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware.nix ];

  myConfig = {
    wm = "$wm";
    isLaptop = $is_laptop;
    userName = "$user_name";
    # configDir = "/home/$user_name/nixos-config"; # Standard — nur ändern wenn Repo woanders liegt
  };

  networking.hostName = "$host";

  users.users.$user_name = {
    isNormalUser = true;
    description = "Hauptbenutzer";
    extraGroups = [ "wheel" "networkmanager" "disk" "storage" ];
  };

  users.mutableUsers = true;
  system.stateVersion = "26.05";
}
EOF

  cat >"$dir/hardware.nix" <<'EOF'
{ ... }:
{
  imports = [
    ./hardware-nixos.nix
    ./hardware-extra.nix
  ];
}
EOF

  cat >"$dir/hardware-nixos.nix" <<'EOF'
# Placeholder — von bootstrap.sh mit /etc/nixos/hardware-configuration.nix
# überschrieben (nur im Working Tree). git sieht immer diese Datei.
{ ... }: {}
EOF

  cat >"$dir/hardware-extra.nix" <<EOF
# Persistente Hardware-Konfiguration für $host.
# Wird committet und bleibt über Neuinstallationen erhalten.
#
# Hier kommen Dinge rein, die nixos-generate-config NICHT automatisch erkennt:
#   - Persistente Datenmounts (externe Festplatten, NAS, etc.)
#   - Zusätzliche Swap-Partitionen
#   - Hardware-spezifische Kernel-Parameter
{ config, lib, pkgs, modulesPath, ... }:

{
  # fileSystems."/data" = {
  #   device = "/dev/disk/by-label/$host-data";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };
}
EOF

  git -C "$REPO_ROOT" add "$dir/configuration.nix" "$dir/hardware.nix" "$dir/hardware-extra.nix" "$dir/hardware-nixos.nix"
  git -C "$REPO_ROOT" commit -m "bootstrap: Host '$host' angelegt"

  echo ""
  echo "✓ $dir/configuration.nix"
  echo "✓ $dir/hardware.nix       (importiert /etc/nixos/hardware-configuration.nix)"
  echo "✓ $dir/hardware-extra.nix (persistente Einstellungen — hier Mounts eintragen)"
  echo "  Bitte configuration.nix vor dem Rebuild prüfen und ggf. anpassen."
}

# ── Host-Auswahl ──────────────────────────────────────────────────────────────

list_hosts() {
  for host in "$REPO_ROOT/hosts"/*/; do
    [ -d "$host" ] && basename "$host"
  done
}

select_host() {
  mapfile -t hosts < <(list_hosts || true)

  echo ""
  echo "Welchen Host möchtest du installieren?"
  echo "  1) Neuen Host anlegen"
  local i=2
  for host in "${hosts[@]}"; do
    echo "  $i) $host"
    i=$((i+1))
  done
  echo "  0) Abbrechen"

  while true; do
    read -rp "Auswahl [0-$((i-1))]: " choice
    case "$choice" in
      0) echo "Abgebrochen."; exit 0 ;;
      1)
        while true; do
          read -rp "Name des neuen Hosts: " host
          [ -z "$host" ] && { echo "Bitte einen Hostnamen eingeben."; continue; }
          [ -d "$REPO_ROOT/hosts/$host" ] && { echo "Host '$host' existiert bereits."; continue; }
          HOST_NAME="$host"; create_host_skeleton "$HOST_NAME"; return
        done ;;
      ''|*[!0-9]*) echo "Bitte eine Zahl eingeben." ;;
      *)
        if [ "$choice" -ge 2 ] && [ "$choice" -lt "$i" ]; then
          HOST_NAME="${hosts[$((choice-2))]}"; return
        fi
        echo "Ungültige Auswahl." ;;
    esac
  done
}

# ── Argumente ─────────────────────────────────────────────────────────────────

[ "$#" -gt 2 ] && usage

HOST_NAME="${1:-}"
KEY_SOURCE="${2:-}"

if [ -z "$HOST_NAME" ]; then
  select_host
elif [ ! -d "$REPO_ROOT/hosts/$HOST_NAME" ]; then
  read -rp "Host '$HOST_NAME' existiert nicht. Neuen Host anlegen? [y/N]: " confirm
  case "${confirm:-N}" in
    [yY]|[yY][eE][sS]) create_host_skeleton "$HOST_NAME" ;;
    *) echo "Abgebrochen."; exit 0 ;;
  esac
fi

# ── Hardware-Config einspielen ────────────────────────────────────────────────
# hardware-nixos.nix ist als Placeholder committet. bootstrap.sh überschreibt
# ihn im Working Tree mit der echten /etc/nixos/hardware-configuration.nix.
# git sieht dank --skip-worktree immer den Placeholder — nie die echte Config.

HARDWARE_NIXOS="$REPO_ROOT/hosts/$HOST_NAME/hardware-nixos.nix"
HARDWARE_NIXOS_REL="hosts/$HOST_NAME/hardware-nixos.nix"

if [ -f /etc/nixos/hardware-configuration.nix ]; then
  cp /etc/nixos/hardware-configuration.nix "$HARDWARE_NIXOS"
  git -C "$REPO_ROOT" update-index --skip-worktree "$HARDWARE_NIXOS_REL"
  echo "✓ hardware-nixos.nix mit echter Hardware-Config befüllt (git sieht nur Placeholder)."
else
  echo "" >&2
  echo "Warnung: /etc/nixos/hardware-configuration.nix nicht gefunden." >&2
  echo "nixos-generate-config ausführen und bootstrap erneut starten." >&2
fi

# ── Schlüssel-Setup ───────────────────────────────────────────────────────────
#
# Strategie:
#   1. Alter age-Key (Übergangslösung): von USB kopieren → für sops updatekeys
#   2. YubiKey auto-detektieren und in .sops.yaml eintragen
#   3. SSH-Host-Key als age-Empfänger registrieren
#   4. Bei Änderungen: sops updatekeys ausführen und committen

SOPS_YAML="$REPO_ROOT/.sops.yaml"
SECRETS_YAML="$REPO_ROOT/secrets/secrets.yaml"
sops_yaml_changed=false

echo ""
echo "=== Schlüssel-Setup ==="

# 1. Alter Key (Übergangslösung) -----------------------------------------------
if [ -z "$KEY_SOURCE" ]; then
  KEY_SOURCE="$(find_key_file || true)"
  [ -n "$KEY_SOURCE" ] && echo "Alter age-Key gefunden: $KEY_SOURCE"
fi

if [ -n "$KEY_SOURCE" ]; then
  if [ ! -f "$KEY_SOURCE" ]; then
    echo "Fehler: Key-Datei nicht gefunden: $KEY_SOURCE" >&2; exit 1
  fi
  mkdir -p "$HOME/.config/sops/age"
  echo "Kopiere alter age-Key → ~/.config/sops/age/keys.txt (Übergangslösung)"
  cp "$KEY_SOURCE" "$HOME/.config/sops/age/keys.txt"
fi

# 2. YubiKey auto-detektieren --------------------------------------------------
if detect_and_add_yubikey; then
  sops_yaml_changed=true
fi

# 3. SSH-Host-Key registrieren -------------------------------------------------
if setup_ssh_age_key "$HOST_NAME"; then
  sops_yaml_changed=true
fi

# 4. SOPS-Empfänger aktualisieren ----------------------------------------------
if [ "$sops_yaml_changed" = true ]; then
  echo ""
  echo "Aktualisiere SOPS-Empfänger in secrets.yaml..."
  echo "  → Benötigt: YubiKey eingesteckt ODER ~/.config/sops/age/keys.txt vorhanden."

  if ! sops updatekeys --yes "$SECRETS_YAML"; then
    echo "" >&2
    echo "Fehler: sops updatekeys fehlgeschlagen." >&2
    echo "Voraussetzungen für die Entschlüsselung:" >&2
    echo "  • YubiKey eingesteckt (age-plugin-yubikey), ODER" >&2
    echo "  • ~/.config/sops/age/keys.txt (alter Key) vorhanden" >&2
    git -C "$REPO_ROOT" checkout -- .sops.yaml
    exit 1
  fi

  git -C "$REPO_ROOT" add .sops.yaml secrets/secrets.yaml
  git -C "$REPO_ROOT" commit -m "bootstrap: SOPS-Empfänger aktualisiert (${HOST_NAME}-ssh hinzugefügt)"
  echo "✓ .sops.yaml und secrets.yaml aktualisiert und committet."
fi

if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
  echo ""
  echo "Hinweis: ~/.config/sops/age/keys.txt fehlt (kein alter Key vorhanden)."
  echo "  Beim ersten Rebuild wird der SSH-Host-Key zur Entschlüsselung genutzt."
fi

# ── Rebuild ───────────────────────────────────────────────────────────────────

echo ""
echo "Starte nixos-rebuild für Host '$HOST_NAME'..."
sudo env NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-rebuild boot --flake "$REPO_ROOT#$HOST_NAME"

echo ""
echo "Fertig! Starte den Rechner neu um den neuen Build zu aktivieren."
echo "Danach: sudo nixos-rebuild switch --flake ~/nixos-config#$HOST_NAME"

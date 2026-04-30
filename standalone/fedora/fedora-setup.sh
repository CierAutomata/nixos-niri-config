#!/usr/bin/env bash
# Fedora post-install setup: Hyprland + home-manager
# Voraussetzung: minimale Fedora-Installation, eingeloggt als briest

set -e

# --- Locale setzen ---
sudo dnf install -y glibc-langpack-de
sudo localectl set-locale LANG=de_DE.UTF-8

# --- System-Updates ---
sudo dnf update -y

# --- COPRs aktivieren ---
# uwsm ist über solopasha/hyprland verfügbar
sudo dnf copr enable -y solopasha/hyprland

# --- Systemweite Pakete per DNF ---
# hyprland ist seit Fedora 40 in den offiziellen Repos verfügbar
sudo dnf install -y \
    uwsm \
    gnome-keyring \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    mesa-dri-drivers \
    mesa-vulkan-drivers \
    xfce-polkit \
    sddm \
    fish \
    git \
    udiskie \
    xdg-utils \
    gvfs \
    nautilus \
    remmina \
    remmina-plugins-rdp \
    freerdp \
    xorg-x11-server-Xorg \
    xorg-x11-server-Xwayland \
    qt5-qtwayland \
    qt6-qtwayland \
    sddm-breeze \
    neovim \
    gh \
    alacritty \
    kitty \
    rclone \
    cava \
    fastfetch \
    btop \
    cmatrix \
    sox \
    firefox \
    jetbrains-mono-fonts \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    wl-clipboard \
    grim \
    slurp \
    xdg-user-dirs \
    xdg-user-dirs-gtk \
    network-manager-applet \
    playerctl \
    pavucontrol \
    blueman

# --- Noctalia via Terra Repo ---
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install -y noctalia-shell

# --- Brave Browser ---
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo dnf install -y brave-browser

# --- SELinux deaktivieren ---
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# --- SDDM aktivieren + auf Xorg setzen ---
sudo mkdir -p /etc/sddm.conf.d
printf '[General]\nDisplayServer=x11\n\n[Users]\nMinimumUid=1000\nMaximumUid=29999\n' | sudo tee /etc/sddm.conf.d/10-display-server.conf
sudo systemctl enable sddm

# --- Nix installieren (Determinate Systems) ---
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# --- nixos-config klonen ---
git clone https://github.com/CierAutomata/nixos-config.git ~/nixos-config

# --- home-manager anwenden ---
rm -f ~/.bashrc
nix run home-manager -- switch --flake ~/nixos-config#fedora --impure

# --- fish als Standard-Shell setzen ---
chsh -s /usr/bin/fish

echo "Fertig. Neustart empfohlen."

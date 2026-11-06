#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "================================"
echo "       JAD-DWM INSTALLER"
echo "================================"


# Install dependencies
echo "[1/6] Installing dependencies..."

sudo pacman -S --needed \
    base-devel git curl \
    libx11 libxft libxinerama \
    freetype2 pkgconf fastfetch \
    feh xorg-xrandr xorg-server \
    xorg-xinit xorg-xauth networkmanager \
    network-manager-applet pipewire-pulse \
    picom mpv thunar vlc

# Backup existing configurations
backup_file() {
    if [ -e "$1" ]; then
        mkdir -p "$BACKUP"
        cp -a "$1" "$BACKUP/"
    fi
}

echo "[2/6] Installing Fastfetch..."

mkdir -p "$HOME/.config/fastfetch"

backup_file "$HOME/.config/fastfetch/config.jsonc"

cp "$DOTFILES/config/fastfetch/config.jsonc" \
   "$HOME/.config/fastfetch/config.jsonc"

# Build DWM 6.8
echo "[3/6] Building DWM..."

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fL https://dl.suckless.org/dwm/dwm-6.8.tar.gz \
    -o "$TMP/dwm.tar.gz"

tar -xzf "$TMP/dwm.tar.gz" -C "$TMP"

cd "$TMP/dwm-6.8"

cp "$DOTFILES/dwm/config.h" .
cp "$DOTFILES/dwm/config.mk" .

make
sudo make install

# Build slstatus
echo "[4/6] Building slstatus..."

cd "$DOTFILES/slstatus"

make clean || true
make
sudo make install

# Install startup script
echo "[5/6] Installing startup script..."

if [ -f "$DOTFILES/scripts/start-dwm" ]; then
    mkdir -p "$HOME/.local/bin"

    backup_file "$HOME/.local/bin/start-dwm"

    cp "$DOTFILES/scripts/start-dwm" \
       "$HOME/.local/bin/start-dwm"

    chmod +x "$HOME/.local/bin/start-dwm"
fi

echo "[6/6] Installation complete!"

echo "================================"
echo "       JAD-DWM INSTALLED"
echo "================================"

echo "Backups saved in: $BACKUP"
echo "You may need to configure your display manager."

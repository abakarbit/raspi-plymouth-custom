#!/bin/bash

# === Check root ===
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi


THEME_NAME="abit"
THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"

mkdir -p "$THEME_DIR"
cp * "$THEME_DIR"

# === Set theme ===
plymouth-set-default-theme "$THEME_NAME"
update-initramfs -u -k all
echo "✅ Done! Reboot to see your new splash screen."

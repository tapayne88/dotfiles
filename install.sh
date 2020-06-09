#!/bin/sh
set -e

CWD=`pwd`
INSTALL_LOCATION="$CWD/dotfiles"
REPO="git@github.com:tapayne88/dotfiles.git"
CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
CHEZMOI_CONFIG_FILE="$CHEZMOI_CONFIG_DIR/chezmoi.json"
CHEZMOI_CONFIG="{
  \"sourceDir\": \"$INSTALL_LOCATION\",
  \"merge\": {
    \"args\": \"-d\",
    \"command\": \"nvim\"
  },
  \"data\": {}
}"

if [ -d "$INSTALL_LOCATION" ]; then
  echo "Found $INSTALL_LOCATION, halting"
  exit 1
fi

echo "Cloning $REPO to $INSTALL_LOCATION"
git clone $REPO $INSTALL_LOCATION
chmod 700 $INSTALL_LOCATION

if [ -f "$CHEZMOI_CONFIG_FILE" ]; then
  echo "Found $CHEZMOI_CONFIG_FILE, halting"
  echo "Merge config with current file"
  echo "$CHEZMOI_CONFIG"
  exit 1
fi

mkdir -p $CHEZMOI_CONFIG_DIR
echo "$CHEZMOI_CONFIG" > $CHEZMOI_CONFIG_FILE

echo ""
echo "Next stps:
Install chezmoi from https://github.com/twpayne/chezmoi

# Dry-run
chezmoi apply -vn

# Apply dotfiles
chezmoi apply -v"

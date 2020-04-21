#!/bin/sh
set -e

CWD=`pwd`
INSTALL_LOCATION="$CWD/dotfiles"
REPO="git@github.com:tapayne88/dotfiles.git"
CHEZMOI_CONFIG_LOCATION="$HOME/.config/chezmoi/chezmoi.json"
CHEZMOI_CONFIG="{
  \"sourceDir\": \"$INSTALL_LOCATION\",
  \"merge\": {
    \"args\": \"-d\",
    \"command\": \"nvim\"
  },
  \"data\": {
    \"tmux_location\": \"`which tmux`\"
  }
}"

if [ -d "$INSTALL_LOCATION" ]; then
  echo "Found $INSTALL_LOCATION, halting"
  exit 1
fi

echo "Cloning $REPO to $INSTALL_LOCATION"
git clone $REPO $INSTALL_LOCATION
chmod 700 $INSTALL_LOCATION

if [ -f "$CHEZMOI_CONFIG_LOCATION" ]; then
  echo "Found $CHEZMOI_CONFIG_LOCATION, halting"
  echo "Merge config with current file"
  echo "$CHEZMOI_CONFIG"
  exit 1
fi

echo "$CHEZMOI_CONFIG" > $CHEZMOI_CONFIG_LOCATION

echo ""
echo "Next stps:
Install chezmoi from https://github.com/twpayne/chezmoi

# Dry-run
chezmoi apply -vn

# Apply dotfiles
chezmoi apply -v"

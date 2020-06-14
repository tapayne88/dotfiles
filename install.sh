#!/bin/sh
set -e

COMMANDS="git curl"
for C in $COMMANDS
do
  command -v $C >/dev/null 2>&1 || {
    echo >&2 "I require $C but it's not installed. Aborting.";
    exit 1;
  }
done

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

# Install vim-plug
curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo ""
echo "Next stps:"

command -v home-manager >/dev/null 2>&1 || { echo >&2 "Install chezmoi from https://github.com/rycee/home-manager"; }
command -v chezmoi >/dev/null 2>&1 || { echo >&2 "Install home-manager from https://github.com/twpayne/chezmoi"; }

echo ""
echo "# Dry-run
chezmoi apply -vn

# Apply dotfiles
chezmoi apply -v"

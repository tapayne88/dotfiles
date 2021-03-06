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
  \"\$schema\": \"https://raw.githubusercontent.com/tapayne88/dotfiles/master/public/chezmoi-schema.json\",
  \"sourceDir\": \"$INSTALL_LOCATION\",
  \"merge\": {
    \"args\": \"-d\",
    \"command\": \"nvim\"
  },
  \"data\": {}
}"

NIX_HOME_DIR="$HOME/.config/nixpkgs"
NIX_HOME_FILE="$NIX_HOME_DIR/home.nix"
NIX_HOME_BOOTSTRAP="{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  # Fix I/O error when writing XML
  xdg.mime.enable = false;

  # Basic packages to setup the rest
  home.packages = [
    pkgs.chezmoi
    pkgs.git
    pkgs.openssh
  ];
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

mkdir -p $NIX_HOME_DIR
echo "$NIX_HOME_BOOTSTRAP" > $NIX_HOME_FILE

echo "Installing vim-plug for neovim"
curl -fLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo ""
echo "Next stps:"

command -v nix-env >/dev/null 2>&1 || { echo >&2 "Install nix from https://nixos.org/download.html"; }
command -v home-manager >/dev/null 2>&1 || { echo >&2 "Install home-manager from https://github.com/nix-community/home-manager"; }

echo ""
echo "# Install home-manager bootstrap packages
home-manager switch

# Dry-run
chezmoi apply -vn

# Apply dotfiles
chezmoi apply -v

# Now install the provisioned packages
home-manager switch"

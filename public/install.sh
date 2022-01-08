#!/bin/sh
set -e

NOFORMAT='\033[0m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'

oops() {
  echo "$0:" "${RED}" "$@" "${NOFORMAT}" >&2
  exit 1
}

msg() {
  echo "$0:" "${BLUE}" "$@" "${NOFORMAT}" >&2
}

require_util() {
  command -v "$1" > /dev/null 2>&1 ||
    oops "you do not have '$1' installed, $2"
}

require_util git "please install it"
require_util nix-env "please install from https://nixos.org/download.html"
require_util home-manager "please install from https://github.com/nix-community/home-manager"

CWD=$(pwd)
DEFAULT_INSTALL_LOCATION="$CWD/dotfiles"

msg "Enter dotfiles install path [$DEFAULT_INSTALL_LOCATION]"
read -r answer < /dev/tty
INSTALL_LOCATION=${answer:-$DEFAULT_INSTALL_LOCATION}

REPO="git@github.com:tapayne88/dotfiles.git"
msg "Cloning $REPO to $INSTALL_LOCATION"
command git clone $REPO "$INSTALL_LOCATION"
chmod 700 "$INSTALL_LOCATION"

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

msg "Applying chezmoi config
$CHEZMOI_CONFIG"

if [ -f "$CHEZMOI_CONFIG_FILE" ]; then
  oops "Found $CHEZMOI_CONFIG_FILE, merge config with existing file"
fi

mkdir -p "$CHEZMOI_CONFIG_DIR"
echo "$CHEZMOI_CONFIG" > "$CHEZMOI_CONFIG_FILE"

mkdir -p "$NIX_HOME_DIR"
echo "$NIX_HOME_BOOTSTRAP" > "$NIX_HOME_FILE"

msg "apply home-manager bootstrap"
home-manager switch

msg "cleaning up temporary files"
rm -f "$NIX_HOME_FILE"

msg "installing asdf..."
command git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0

msg "installing asdf plugins..."
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add pnpm

echo ""
echo "${GREEN}Next steps:${NOFORMAT}
# Apply dotfiles with chezmoi, chechout the required schema with this URL
# https://github.com/tapayne88/dotfiles/blob/master/public/chezmoi-schema.json
${BLUE}chezmoi apply -v${NOFORMAT}

# Install the provisioned packages
${BLUE}home-manager switch${NOFORMAT}
"

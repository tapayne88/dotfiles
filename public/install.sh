#!/bin/sh
set -e

oops() {
  echo "$0:" "$@" >&2
  exit 1
}

require_util() {
  command -v "$1" > /dev/null 2>&1 ||
    oops "you do not have '$1' installed, $2"
}


COMMANDS="git curl"
for C in $COMMANDS
do
  require_util "$C" "please install"
done

CWD=$(pwd)
DEFAULT_INSTALL_LOCATION="$CWD/dotfiles"

NOFORMAT='\033[0m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo "${BLUE}Enter dotfiles install path [$DEFAULT_INSTALL_LOCATION] (relative or absolute)${NOFORMAT}"
read -r answer < /dev/tty
INSTALL_LOCATION=${answer:-$DEFAULT_INSTALL_LOCATION}

# Ensure location doesn't exist
if [ -d "$INSTALL_LOCATION" ]; then
  oops "${RED}Install location already exists ($(cd "$INSTALL_LOCATION"; pwd))${NOFORMAT}"
fi

# Ensure location path does exist
if [ ! -d "$(dirname "$INSTALL_LOCATION")" ]; then
  oops "${RED}Install location path invalid ($INSTALL_LOCATION)${NOFORMAT}"
fi

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

echo "Cloning $REPO to $INSTALL_LOCATION"
command git clone $REPO "$INSTALL_LOCATION"
chmod 700 "$INSTALL_LOCATION"

echo "Applying chezmoi config
$CHEZMOI_CONFIG"

if [ -f "$CHEZMOI_CONFIG_FILE" ]; then
  oops "${RED}Found $CHEZMOI_CONFIG_FILE, merge config with existing file${NOFORMAT}"
fi

mkdir -p "$CHEZMOI_CONFIG_DIR"
echo "$CHEZMOI_CONFIG" > "$CHEZMOI_CONFIG_FILE"

mkdir -p "$NIX_HOME_DIR"
echo "$NIX_HOME_BOOTSTRAP" > "$NIX_HOME_FILE"

require_util nix-env "${YELLOW}# Install nix from https://nixos.org/download.html${NOFORMAT}"
require_util home-manager "${YELLOW}# Install home-manager from https://github.com/nix-community/home-manager${NOFORMAT}"

echo "apply home-manager bootstrap"
home-manager switch

# Remove temporary home-manager file
echo "cleaning up temporary files"
rm -f "$NIX_HOME_FILE"

echo ""
echo "${GREEN}Next steps:${NOFORMAT}
# Apply dotfiles with chezmoi, chechout the required schema with this URL
# https://github.com/tapayne88/dotfiles/blob/master/public/chezmoi-schema.json
${BLUE}chezmoi apply -v${NOFORMAT}

# Install the provisioned packages
${BLUE}home-manager switch${NOFORMAT}

# Install asdf https://asdf-vm.com/guide/getting-started.html#_2-download-asdf
${BLUE}git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0${NOFORMAT}

# Install asdf plugins
# https://github.com/tapayne88/dotfiles/blob/2b7d0baaeba11ef0af5b2f67bbe16ff64c828859/README.md?plain=1#L51-L55
"

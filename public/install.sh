#!/bin/sh
set -e

COMMANDS="git curl"
for C in $COMMANDS
do
  command -v "$C" >/dev/null 2>&1 || {
    echo >&2 "I require $C but it's not installed. Aborting.";
    exit 1;
  }
done

CWD=$(pwd)
DEFAULT_INSTALL_LOCATION="$CWD/dotfiles"

NOFORMAT='\033[0m'
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo "${BLUE}Enter dotfiles install path [$DEFAULT_INSTALL_LOCATION] (relative or absolute)${NOFORMAT}"
read -r answer
INSTALL_LOCATION=${answer:-$DEFAULT_INSTALL_LOCATION}

# Ensure location doesn't exist
if [ -d "$INSTALL_LOCATION" ]; then
  echo "${RED}Install location already exists, halting${NOFORMAT}"
  echo "${YELLOW}$(cd "$INSTALL_LOCATION"; pwd)${NOFORMAT}"
  exit 1
fi

# Ensure location path does exist
if [ ! -d "$(dirname "$INSTALL_LOCATION")" ]; then
  echo "${RED}Install location path invalid, halting${NOFORMAT}"
  echo "${YELLOW}$INSTALL_LOCATION${NOFORMAT}"
  exit 1
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
git clone $REPO "$INSTALL_LOCATION"
chmod 700 "$INSTALL_LOCATION"

if [ -f "$CHEZMOI_CONFIG_FILE" ]; then
  echo "${RED}Found $CHEZMOI_CONFIG_FILE, halting${NOFORMAT}"
  echo "${YELLOW}Merge config with existing file${NOFORMAT}"
  echo "${YELLOW}$CHEZMOI_CONFIG${NOFORMAT}"
  exit 1
fi

mkdir -p "$CHEZMOI_CONFIG_DIR"
echo "$CHEZMOI_CONFIG" > "$CHEZMOI_CONFIG_FILE"

mkdir -p "$NIX_HOME_DIR"
echo "$NIX_HOME_BOOTSTRAP" > "$NIX_HOME_FILE"

echo ""
echo "${GREEN}Next steps:${NOFORMAT}"

command -v nix-env >/dev/null 2>&1 || { echo >&2 "${YELLOW}# Install nix from https://nixos.org/download.html${NOFORMAT}"; }
command -v home-manager >/dev/null 2>&1 || { echo >&2 "${YELLOW}# Install home-manager from https://github.com/nix-community/home-manager${NOFORMAT}"; }

echo "
# Install home-manager bootstrap packages
${BLUE}home-manager switch${NOFORMAT}

# Apply dotfiles with chezmoi, chechout the required schema with this URL
# https://github.com/tapayne88/dotfiles/blob/master/public/chezmoi-schema.json
${BLUE}chezmoi apply -v${NOFORMAT}

# Remove temporary home-manager file
${BLUE}rm $NIX_HOME_FILE${NOFORMAT}

# Install the provisioned packages
${BLUE}home-manager switch${NOFORMAT}

# Install asdf https://asdf-vm.com/guide/getting-started.html#_2-download-asdf
${BLUE}git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0${NOFORMAT}

# Install asdf plugins
# https://github.com/tapayne88/dotfiles/blob/2b7d0baaeba11ef0af5b2f67bbe16ff64c828859/README.md?plain=1#L51-L55
"

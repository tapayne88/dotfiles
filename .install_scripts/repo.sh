#!/bin/sh

install_repo() {
  local root=$1
  local install_location="$root/dotfiles"
  local repo="git@github.com:tapayne88/dotfiles.git"

  if [ -d "$install_location" ]; then
    echo "Found $install_location, halting"
    exit 1
  fi

  echo "Cloning $repo to $install_location"
  git clone $repo $install_location
  chmod 700 $install_location
}

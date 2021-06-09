# Installation Guide

## 1. Update and install things (Debian only)

```shell
sudo apt update
sudo apt upgrade

# curl for installation script et al.
# xz for nix install
# perl encode module for diff-so-fancy
# build-essentials & pkg-config for rust related things
sudo apt install \
  curl \
  xz-utils \
  liburi-encode-perl \
  build-essential \
  pkg-config
```

## 2. Locale (Debian only)

Reconfigure locale to include en_GB ([source](https://www.thomas-krenn.com/en/wiki/Perl_warning_Setting_locale_failed_in_Debian)).

```shell
sudo locale-gen en_GB.UTF-8
sudo dpkg-reconfigure locales

# Select both en_GB.UTF8 and en_US.UTF8 - default to GB
```

## 3. Install nix and home-manager

- [nix](https://nixos.org/download.html) - to get nix installed on crostini see [`patch-nix`](https://github.com/tapayne88/dotfiles/blob/18080b947f560ff59c0e7fc453b276c0ee9cd548/dot_config/zsh/functions/crostini.zsh#L7) function.
- [home-manager](https://github.com/nix-community/home-manager)

Configuring [channels](https://nixos.wiki/wiki/Nix_channels).

### MacOS

```console
❯ nix-channel --list
home-manager https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz
nixpkgs https://nixos.org/channels/nixpkgs-21.05-darwin
nixpkgs-unstable https://nixos.org/channels/nixpkgs-unstable
```

### \*nix

Note, nix on crostini needs the nixgl channel so `nixGL` can be installed. This enables kitty terminal and probably other nix installed openGL programs to work.

```console
❯ nix-channel  --list
home-manager https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz
nixgl https://github.com/guibou/nixGL/archive/master.tar.gz
nixpkgs https://nixos.org/channels/nixos-21.05
nixpkgs-unstable https://nixos.org/channels/nixpkgs-unstable
```

## 4. Generate ssh key

Generate ssh key and upload to github

```shell
ssh-keygen -C `hostname`
```

## 4. Install dotfiles

See [readme](./README.md#installation) for installation guide.

## 5. Setup shell

Ensure user has a password set and add nix zsh to allowed shells and change shell.

```shell
sudo passwd `whoami`
which zsh | sudo tee --append /etc/shells
chsh -s `which zsh`
```

## 6. Setup terminfo

Dotfiles includes tmux terminfo which needs installing. Likely want to `sudo tic` the terminfo so they are accessible to all system users (like root).

```shell
sudo tic terminfo/tmux.terminfo
sudo tic terminfo/tmux-256color.terminfo
```

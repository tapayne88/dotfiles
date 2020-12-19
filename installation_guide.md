# Installation Guide

## 1. Update and install things (Debian only)

```bash
sudo apt update
sudo apt upgrade

# curl for installation script et al.
# xz for nix install
# perl encode module for diff-so-fancy
sudo apt install curl xz-utils liburi-encode-perl
```

## 2. Locale (Debian only)

Reconfigure locale to include en_GB ([source](https://www.thomas-krenn.com/en/wiki/Perl_warning_Setting_locale_failed_in_Debian)).

```bash
sudo locale-gen en_GB.UTF-8
sudo dpkg-reconfigure locales

# Select both en_GB.UTF8 and en_US.UTF8 - default to GB
```

## 3. Install nix and home-manager

- [nix](https://nixos.org/download.html)
- [home-manager](https://github.com/nix-community/home-manager)

### MacOS

```console
❯ nix-channel --list
home-manager https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz
nixpkgs https://nixos.org/channels/nixpkgs-20.09-darwin
```

### \*nix

```console
❯ nix-channel  --list
home-manager https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz
nixpkgs https://nixos.org/channels/nixpkgs-20.09
```

## 4. Generate ssh key

Generate ssh key and upload to github

```bash
ssh-keygen -C `hostname`
```

## 4. Install dotfiles

See [readme](./README.md#installation) for installation guide.

## 5. Setup shell

Add nix zsh to allowed shells and change shell.

```bash
which zsh | sudo tee --append /etc/shells
chsh -s `which zsh`
```

## 6. Setup terminfo

Dotfiles includes tmux terminfo which needs installing. Likely want to `sudo tic` the terminfo so they are accessible to all system users (like root).

```bash
sudo tic terminfo/tmux.terminfo
sudo tic terminfo/tmux-256color.terminfo
```

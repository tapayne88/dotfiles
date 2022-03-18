# Installation Guide

## 1. Update and install

### Debian

Update installed packages and install packages needed for setup.

```shell
sudo apt update
sudo apt upgrade

# curl for installation script et al.
# xz for nix install
# build-essentials & pkg-config for rust related things
sudo apt install \
  curl \
  xz-utils \
  build-essential \
  pkg-config
```

### MacOS

Install xcode-select developer tools to enable setup.

```shell
xcode-select --install
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
nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager; \
nix-channel --add https://nixos.org/channels/nixpkgs-21.11-darwin nixpkgs;
```

### \*nix

```console
nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager; \
nix-channel --add https://nixos.org/channels/nixos-21.11 nixpkgs;
```

## 4. Generate ssh key

Generate ssh key and upload to github

```shell
ssh-keygen -C `hostname`
```

## 4. Install dotfiles

Run the following and follow the steps.

```bash
curl -sfL https://git.io/JsiiF | sh
```

This will:

- clone this repository
- apply dotfiles using [chezmoi](../README.md#chezmoi)
- setup [nix / home-manager](../README.md#nix) packages
- install [`asdf`](../README.md#asdf) and plugins

## 5. Setup user (Debian only)

Ensure user has a password set - usually required on a fresh Crostini install.

```shell
sudo passwd `whoami`
```

## 6. Setup shell

Add nix installed zsh to allowed shells and change shell to it.

```shell
which zsh | sudo tee --append /etc/shells
chsh -s `which zsh`
```

## 7. Setup [Homebrew](https://brew.sh/) (MacOS only)

After following the homebrew installation instructions we'll want our blessed homebrew packages installing. These are in our `Brewfile` which can be installed with the following command.

```bash
brew bundle install --global
```

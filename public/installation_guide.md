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

```bash
curl -sfL https://git.io/JsiiF | sh
```

or

```bash
git clone https://github.com/tapayne88/dotfiles
```

## 5. Setup shell

Ensure user has a password set and add nix zsh to allowed shells and change shell.

```shell
sudo passwd `whoami`
which zsh | sudo tee --append /etc/shells
chsh -s `which zsh`
```

## 6. Install [`asdf`](https://asdf-vm.com/#/)

Installing should just be cloning the repo into `~/.asdf` and installing the plugins ([docs](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf)).

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.9.0
```

Install the required plugins

```bash
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add pnpm
```

## 7. Setup [Homebrew](https://brew.sh/) (MacOS only)

After following the homebrew installation instructions we'll want our blessed homebrew packages installing. These are in our `Brewfile` which can be installed with the following command.

```bash
brew bundle install --global
```

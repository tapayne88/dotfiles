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
sudo locale-gen en_GB.UTF-8; \
sudo dpkg-reconfigure locales
```

N.B. Select both en_GB.UTF8 and en_US.UTF8 - default to GB

## 3. Install nix and home-manager

- [nix](https://nixos.org/download.html)
- [home-manager](https://github.com/nix-community/home-manager)

Configuring [channels](https://nixos.wiki/wiki/Nix_channels).

### MacOS

```console
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager; \
nix-channel --add https://nixos.org/channels/nixpkgs-25.05-darwin nixpkgs;
```

### \*nix

```console
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager; \
nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs;
```

## 4. Generate ssh key

Generate an ssh key

```shell
ssh-keygen -C `hostname`
```

Upload to

- [Github](https://github.com/settings/keys)
- [GitLab](https://gitlab.com/-/profile/keys)

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
which zsh | sudo tee --append /etc/shells; \
chsh -s `which zsh`
```

## 7. Setup [Homebrew](https://brew.sh/) (MacOS only)

After following the homebrew installation instructions we'll want our blessed homebrew packages installing. These are in our `Brewfile` which can be installed with the following command.

```bash
brew bundle install --global
```

## 8. Font Installation

Ensure chezmoi config specifies the appropriate font name (see [here](https://github.com/tapayne88/dotfiles/blob/c9c49b2fa6c41ca37ed9a1e24e374d72e0379148/public/chezmoi-schema.json#L27-L31)).

The selected Nerd font should

- have ligature support - filename shouldn't contain `NL` (No Ligatures)
- is suitable for terminals / monospaced applications - has `Mono` suffix

_N.B._ As of writing this alacritty does not support ligatures.

### MacOS

MacOS will use homebrew to install the fonts. Use MacOS' builtin Font Book app to verify the font name.

### Linux

Running `chezmoi apply` _should_ put the JetBrainsMono Nerd font files in the correct directory. Following this you'll need to reload the system font cache with

```bash
fc-cache -r
```

The following will show the installed font name and supported styles, e.g. italic, etc.

```bash
fc-list | grep JetBrains
```

### Windows

Double-click each of the font files in the [fonts directory](../dot_local/share/fonts). As of Nerd font v3 there are no Windows specific font files, each font should support all systems.

## 9. Misc

`bat` doesn't bundle the Catppuccin theme so the theme files that are part of this repo need adding to the bat theme cache.

```bash
bat cache --build
```

See the [docs](https://github.com/catppuccin/bat#adding-the-themes)

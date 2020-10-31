# Debian Installation

## 1. Update and install things

```bash
sudo apt update
sudo apt upgrade

# curl for installation script et al.
# xz for nix install
# perl encode module for diff-so-fancy
sudo apt install curl xz-utils liburi-encode-perl
```

## 2. Locale

Reconfigure locale to include en_GB.

```bash
sudo dpkg-reconfigure locales

# Select both en_GB.UTF8 and en_US.UTF8 - default to GB
```

## 3. Install nix and home-manager

- [nix](https://nixos.org/download.html)
- [home-manager](https://github.com/nix-community/home-manager)

Update `~/.config/nixpkgs/home.nix` with the following

```nix
{
  # Fix I/O error when writing XML
  xdg.mime.enable = false;

  # Basic packages to setup the rest
  home.packages = [
    pkgs.chezmoi
    pkgs.git
    pkgs.openssh
  ];
}
```

```bash
home-manager switch
```

## 4. Generate ssh key

Generate ssh key and upload to github

```bash
ssh-keygen -C <os-name>
```

## 4. Install dotfiles

See [readme](./README.md#installation) for installation guide.

## 5. Setup terminfo

Dotfiles includes tmux terminfo which needs installing. Likely want to `sudo tic` the terminfo so they are accessible to all system users (like root).

```bash
sudo tic terminfo/tmux.terminfo
sudo tic terminfo/tmux-256color.terminfo
```

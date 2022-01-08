# Dotfiles

![kitty screenshot](./public/kitty-screenshot.png "Kitty Screenshot")

A place for all my dotfiles and each one in its place.

## Installation

```bash
curl -sfL https://git.io/JsiiF | sh
```

For the full setup guide, follow [this](./public/installation_guide.md).

## [Chezmoi](https://www.chezmoi.io/)

> Manage your dotfiles across multiple machines, securely

I use chezmoi to put all my dotfiles into place and make them work across different OS's.

JSON schema for `~/.config/chezmoi/chezmoi.json` is available [here](./public/chezmoi-schema.json).

## [Nix](https://nixos.org/)

> Nix is a powerful package manager for Linux and other Unix systems that makes package management reliable and reproducible. Share your development and build environments across different machines.

I use Nix (and [home-manager](https://github.com/rycee/home-manager)) to manage my required packages. Things like neovim, tmux, git, etc. all get installed using nix and are configured by [code](./dot_config/nixpkgs/home.nix.tmpl).

## Terminals

| Terminal                                                  | Tested OS                                                               | Managed config | Notes                                                                                                                                                            |
| --------------------------------------------------------- | ----------------------------------------------------------------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Kitty](https://sw.kovidgoyal.net/kitty/) - Preferred     | <ul><li>MacOS</li><li>Chrome OS</li></ul>                               | Yes            | <ul><li>GPU accelerated</li><li>Supports ligatures</li><li>Supports powerline fonts well</li></ul>                                                               |
| [Alacritty](https://github.com/alacritty/alacritty)       | <ul><li>MacOS</li><li>Chrome OS</li><li>Linux</li><li>Windows</li></ul> | Yes            | <ul><li>GPU accelerated</li><li>Very slim feature set (needs tmux)</li><li>Doesn't support ligatures</li><li>Doesn't support powerline fonts very well</li></ul> |
| [Windows Terminal](https://github.com/microsoft/terminal) | <ul><li>Windows</li></ul>                                               | No             | <ul><li>Works well on windows</li></ul>                                                                                                                          |

## Colour scheme

Download [Nord theme](https://www.nordtheme.com/) from the website for terminal of choice.

## [`asdf`](https://asdf-vm.com/#/)

`asdf` is a great tool for managing multiple versions of the same software, e.g. node, yarn.

```bash
asdf plugin add nodejs
asdf plugin add yarn
asdf plugin add pnpm
```

## Fonts

To get ligature/italic font support there are a number of steps. You'll want to source a font like [JetBrains Mono](https://www.jetbrains.com/lp/mono/) and install it. If you want icons you'll probably want the [Nerd Fonts](https://www.nerdfonts.com/font-downloads) version.

### Linux

```shell
sudo fc-cache -f -v
```

- Ensure `chezmoi` has applied the fonts to `~/.local/share/fonts`

### MacOS

- Double click and install each font in [here](./dot_local/share/fonts)

### Windows

- Double click and install each font in [here](./dot_local/share/fonts/windows)
- Windows Terminal doesn't support italics

_N.B._ As of writing this alacritty does not support ligatures.

## SSH

Example `~/.ssh/config`

```sshconfig
Include ~/git/dotfiles/misc/ssh_config
```

## Windows Utilities

| Utility                                                 | Description                                                                          |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [scoop](https://scoop.sh/)                              | Windows version of [homebrew](https://brew.sh/)                                      |
| [xdg-open-wsl](https://github.com/cpbotha/xdg-open-wsl) | Make things like vim's `MarkdownPreview` work                                        |
| [sharpkeys](https://github.com/randyrants/sharpkeys)    | Remap individual keys - useful for HHKB on windows without messing with dip switches |
| [PowerToys](https://github.com/microsoft/PowerToys)     | Nice tools, good for keyboard chord remapping                                        |

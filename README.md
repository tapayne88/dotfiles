# Dotfiles

A place for all my dotfiles and each one in its place.

## Installation

```bash
curl -sfL https://git.io/JvlgU | sh

# or

git clone https://github.com/tapayne88/dotfiles
```
Files managed using [chezmoi](https://www.chezmoi.io/), packages managed using [nix](https://nixos.org/download.html) and [home-manager](https://github.com/rycee/home-manager).

For debian specific setup guide, follow [this](./debian_installation.md).

## Terminal

Terminal of choice is [Alacritty](https://github.com/alacritty/alacritty) but Windows Terminal seems good too.

## Colour scheme

Download [Nord theme](https://www.nordtheme.com/) from the website for terminal of choice.

## [`asdf`](https://asdf-vm.com/#/)

`asdf` is a great tool for managing multiple versions of the same software, e.g. node, yarn

## Fonts

To get ligature/italic font support there are a number of steps.
- source a font like [JetBrains Mono](https://www.jetbrains.com/lp/mono/) and install it
  - dotfiles includes JetBrains Mono font for linux, just need to run
  ```shell
  sudo fc-cache -f -v
  ```
- ensure terminal is configured for italic fonts (iterm2 needs a box checking)
- configure new terminfo to ensure correct escape characters are used

*N.B.* As of writing this alacritty does not support ligatures.

## Terminfo

Likely want to `sudo tic` the terminfo so they are accessible to all system users (like root).

From `man tic`

> Secondly,  if  tic  cannot write in /etc/terminfo or the location specified using your TERMINFO variable, it looks for the directory $HOME/.terminfo (or hashed database $HOME/.terminfo.db); if that location exists, the  entry  is  placed there.

```bash
sudo tic terminfo/tmux.terminfo
sudo tic terminfo/tmux-256color.terminfo
```

## SSH

Example `~/.ssh/config`

```
Include ~/git/dotfiles/misc/ssh_config
```

## Troubleshooting

### CoC Slow
I've found in the past if neovim has to resolve the neovim npm module it can mean some plugins are slow. I noticed this with CoC being slow to show and move between options in the autocomplete menu. To fix this you can set the `node_host_prog` manually to point to the correct location (may differ per host).

I've configured neovim to look for a `~/.vimrc.local` file and load it if found. To fix the above problem it should look something like
```vimscript
let g:node_host_prog = '/home/linuxbrew/.linuxbrew/lib/node_modules/neovim'
```

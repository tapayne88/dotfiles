# Dotfiles

A place for all my dotfiles and each one in its place.

## Installation

```bash
curl -sfL https://git.io/JvlgU | sh

# or

git clone https://github.com/tapayne88/dotfiles
```

For the full setup guide, follow [this](./installation_guide.md).

## [Chezmoi](https://www.chezmoi.io/)

> Manage your dotfiles across multiple machines, securely

I use chezmoi to put all my dotfiles into place and make them work across different OS's.

JSON schema for `~/.config/chezmoi/chezmoi.json` is available [here](./chezmoi-schema.json).

## [Nix](https://nixos.org/)

> Nix is a powerful package manager for Linux and other Unix systems that makes package management reliable and reproducible. Share your development and build environments across different machines.

I use Nix (and [home-manager](https://github.com/rycee/home-manager)) to manage my required packages. Things like neovim, tmux, git, etc. all get installed using nix and are configured by [code](./dot_config/nixpkgs/home.nix.tmpl).

## Terminals

| Terminal                                                  | Tested OS                                                               | Managed config | Notes                                                                                                                                                            |
|-----------------------------------------------------------|-------------------------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Alacritty](https://github.com/alacritty/alacritty)       | <ul><li>MacOS</li><li>Chrome OS</li><li>Linux</li><li>Windows</li></ul> | Yes            | <ul><li>GPU accelerated</li><li>Very slim feature set (needs tmux)</li><li>Doesn't support ligatures</li><li>Doesn't support powerline fonts very well</li></ul> |
| [Kitty](https://sw.kovidgoyal.net/kitty/)                 | <ul><li>MacOS</li><li>Chrome OS</li></ul>                               | Yes            | <ul><li>GPU accelerated</li><li>Supports ligatures</li><li>Supports powerline fonts well</li></ul>                                                               |
| [Windows Terminal](https://github.com/microsoft/terminal) | <ul><li>Windows</li></ul>                                               | No             | <ul><li>Works well on windows</li></ul>                                                                                                                          |


## Colour scheme

Download [Nord theme](https://www.nordtheme.com/) from the website for terminal of choice.

## [`asdf`](https://asdf-vm.com/#/)

`asdf` is a great tool for managing multiple versions of the same software, e.g. node, yarn.

```bash
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin-add yarn https://github.com/twuni/asdf-yarn
```

## Fonts

To get ligature/italic font support there are a number of steps. You'll want to source a font like [JetBrains Mono](https://www.jetbrains.com/lp/mono/) and install it. If you want icons you'll probably want the [Nerd Fonts](https://www.nerdfonts.com/font-downloads) version.

### Installation

#### Linux

- Ensure `chezmoi` has applied the fonts to `~/.local/share/fonts`
- Force the font cache to reload
```shell
sudo fc-cache -f -v
```
- Configure new terminfo to ensure correct escape characters are used

#### MacOS

- Double click and install each font in [here](./dot_local/share/fonts)
- Configure new terminfo to ensure correct escape characters are used

#### Windows

- Double click and install each font in [here](./dot_local/share/fonts/windows)
- Windows Terminal doesn't support italics
- Configure new terminfo to ensure correct escape characters are used

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

A good way to get the path to the `neovim` module is using the following. Ensure you have your system `npm` active when running.

```bash
npm config get prefix
```

It should return something like below, simply add `lib/node_modules/neovim`

```bash
❯ ~ npm config get prefix
/nix/store/vbbqhpb47jlz6acgb698hgf75i53scm2-nodejs-12.18.0
```

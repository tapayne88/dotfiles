# Dotfiles

A place for all my dotfiles and each one in its place.

Files managed using [chezmoi](https://www.chezmoi.io/).
```shell
git clone git@gitlab.com:tpayne/dotfiles.git ~/.local/share/chezmoi
chezmoi apply
```

## Colour scheme
Download [Nord theme](https://www.nordtheme.com/) from the website for terminal of choice.

## ZSH Shell
Install `zsh` and `zsh-completions`. Currently using [zgen](https://github.com/tarjoilija/zgen) as the plugin manager
```shell
brew install zsh zsh-completions

# Following chezmoi apply
zgen update
```

## Fish Shell
```shell
brew install fish
sudo sh -c "echo `brew --prefix fish` >> /etc/shells"
```

[fisherman](https://github.com/fisherman/fisherman) should install itself on launching fish shell (with `config.fish` in place)

## Silver Searcher
A code-searching tool similar to ack, but faster. [http://geoff.greer.fm/ag/]( http://geoff.greer.fm/ag/)

## Vim (NeoVim)
Using NeoVim.
```shell
# NeoVim
brew install neovim/neovim/neovim

# Ensure fzf is installed
brew install fzf
ln -s `brew --prefix fzf` ~/.fzf

# Python configuration
pip install neovim --upgrade
pip3 install neovim --upgrade

# Check health
nvim +checkhealth

# Install CoC extensions
nvim +'CocInstall coc-eslint coc-tslint coc-prettier coc-json coc-tsserver'
```

### Plugins
Install [Vim Plug](https://github.com/junegunn/vim-plug). Vim Plug should install itself when you open vim for the first time.
```shell
# Now open NeoVim and Vim Plug should attempt to install the plugins
nvim +PlugInstall
```

#### CoC Slow
I've found in the past if neovim has to resolve the neovim npm module it can mean some plugins are slow. I noticed this with CoC being slow to show and move between options in the autocomplete menu. To fix this you can set the `node_host_prog` manually to point to the correct location (may differ per host).

I've configured neovim to look for a `~/.vimrc.local` file and load it if found. To fix the above problem it should look something like
```vimscript
let g:node_host_prog = '/home/linuxbrew/.linuxbrew/lib/node_modules/neovim'
```

## Tmux
Optionally install [tmuxp](https://tmuxp.git-pull.com) session manager
```shell
# Setup tmux plugin mananger
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## [`asdf`](https://asdf-vm.com/#/)
`asdf` is a great tool for managing multiple versions of the same software, e.g. node, yarn

## Misc
```shell
# Git config uses diff-so-fancy
brew install diff-so-fancy
# OR
curl -s -l https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -o ~/.local/bin/diff-so-fancy

chmod +x ~/.local/bin/diff-so-fancy
```
(dir_colors from [nord-dircolors](https://github.com/arcticicestudio/nord-dircolors))

### SSH
Example `~/.ssh/config`
```
Include ~/git/dotfiles/misc/ssh_config
```

## Fonts
To get ligature/italic font support there are a number of steps.
- source a font like [JetBrains Mono](https://www.jetbrains.com/lp/mono/) and install it
- ensure terminal is configured for italic fonts (iterm2 needs a box checking)
- configure new terminfo to ensure correct escape characters are used

*N.B.* As of writing this alacritty does not support ligatures.

```shell
# for each file in terminfo folder
tic terminfo/tmux-256color.terminfo
```

## MacOS Specific
### iTerm2
Keybindings
```
# Set iTerm2 to switch tmux windows with Cmd+{ and Cmd+}
0x02 0x6E   Cmd + }			next window
0x02 0x70   Cmd + {			previous window

^[ b		Alt + <-		previous word
^[ f		Alt + ->		next word
```

## General
- Install [Homebrew](http://brew.sh/)
- Install utilities
- Replace BSD tools with GNU [here](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/)

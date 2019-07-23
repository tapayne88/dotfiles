# Dotfiles

Get em while they're hot!

### Directories
```
mkdir -p ~/.local/bin
mkdir -p ~/.config
```

### Colour scheme
Download [Nord theme](https://www.nordtheme.com/) from the website for terminal of choice.

### ZSH Shell
Install `zsh` and `zsh-completions`. Currently using [zplug](https://github.com/zplug/zplug) as the plugin manager

### Fish Shell
```
brew install fish
sudo sh -c "echo /usr/local/bin/fish >> /etc/shells"

ln -s -f (pwd)/fish/config/* ~/.config/fish/
ln -s -f (pwd)/fish/functions/* ~/.config/fish/functions/
```

[fisherman](https://github.com/fisherman/fisherman) should install itself on launching fish shell (with `config.fish` in place)

### Silver Searcher
A code-searching tool similar to ack, but faster. [http://geoff.greer.fm/ag/]( http://geoff.greer.fm/ag/)

### Vim
Primarily using neovim but `nvim/init.vim` is a hard link to `vim/vimrc`, the config is shared across both to ease switching between them.
```
# NeoVim
brew install neovim/neovim/neovim

# Python configuration
pip install neovim --upgrade
pip3 install neovim --upgrade

# Check health
nvim +checkhealth

# Vim
# We're only interested in > Vim 8
brew install vim
```

#### Symlinks
```
ln -s (pwd)/vim ~/.vim
ln -s (pwd)/vim/vimrc ~/.vimrc
ln -s (pwd)/nvim ~/.config/nvim
```

#### Plugins
Install [Vim Plug](https://github.com/junegunn/vim-plug). Vim Plug should install itself when you open vim for the first time.
```
# Now open Vim and Vim Plug should attempt to install the plugins
nvim +PlugInstall
vim +PlugInstall
```

### Tmux
Optionally install [tmuxp](https://tmuxp.git-pull.com) session manager
```
# Setup tmux plugin mananger
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Link config
ln -s (pwd)/tmux/tmux.conf ~/.tmux.conf
ln -s (pwd)/tmux/helpers ~/.tmux/helpers
ln -s (pwd)/tmux/tmuxp ~/.tmuxp
```

### Config
```
ln -s (pwd)/config/gitconfig ~/.gitconfig
ln -s (pwd)/config/tern-config ~/.tern-config
```

### Misc
```
# scripts
ln -s (pwd)/scripts/* ~/.local/bin

# Git config uses diff-so-fancy
brew install diff-so-fancy
# OR
curl -s -l https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -o ~/.local/bin/diff-so-fancy
chmod +x ~/.local/bin/diff-so-fancy

# dir_colors
ln -s (pwd)/misc/dir_colors ~/.dir_colors
```
(dir_colors from [nord-dircolors](https://github.com/arcticicestudio/nord-dircolors))

#### SSH
Example `~/.ssh/config`
```
Include ~/git/dotfiles/misc/ssh_config
```

### Fonts
To get ligature/italic font support there are a number of steps.
- source a font like [Dank Mono](https://dank.sh) and install it
- ensure terminal is configured for italic fonts (iterm2 needs a box checking)
- configure new terminfo to ensure correct escape characters are used

```
# for each file in terminfo folder
tic terminfo/tmux-256color.terminfo
```

## MacOS Specific
#### iTerm2
Keybindings
```
# Set iTerm2 to switch tmux windows with Cmd+{ and Cmd+}
0x02 0x6E   Cmd + }			next window
0x02 0x70   Cmd + {			previous window

^[ b		Alt + <-		previous word
^[ f		Alt + ->		next word
```

## Linux Specific
#### gnome-terminal
```
# custom terminal command
env TERM_PROGRAM=gnome-terminal /usr/bin/fish
```

#### General
- Install [Homebrew](http://brew.sh/)
- Install utilities
- Replace BSD tools with GNU [here](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/)

For some brew modules you may want to install see [brew_leaves.txt](./brew_leaves.txt)

# Dotfiles

Get em while they're hot!

### Directories
```
mkdir -p ~/.local/bin
mkdir -p ~/.config
```

Color Scheme: [base16](https://github.com/chriskempson/base16)

### Fish Shell
```
brew install fish
sudo sh -c "echo /usr/local/bin/fish >> /etc/shells"
```

[fisherman](https://github.com/fisherman/fisherman)

Functions contains modified version of prompt (`fish_prompt.fish`)
```
curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
fisher

ln -s (pwd)/fish/config/* ~/.config/fish/
ln -s (pwd)/fish/functions/* ~/.config/fish/functions/
```

[base16](https://github.com/chriskempson/base16-shell)
```
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
```

### Silver Searcher
A code-searching tool similar to ack, but faster. [http://geoff.greer.fm/ag/]( http://geoff.greer.fm/ag/)

### Vim
We're only interested in > Vim 8
```
brew install vim
```

#### Symlinks
```
ln -s (pwd)/vim ~/.vim
ln -s (pwd)/vim/vimrc ~/.vimrc
```

#### Plugins
Install [Vim Plug](https://github.com/junegunn/vim-plug). Vim Plug should install itself when you open vim for the first time.
```
# Now open Vim and Vim Plug should attempt to install the plugins
vim +PlugInstall
```

### NeoVim
*Note.* `nvim/init.vim` is a hard link to `vim/vimrc`, the config is shared across both to ease switching between them.
```
brew install neovim/neovim/neovim

# YCM requires python3
brew install python3
pip3 install neovim --upgrade
```

#### Symlinks
```
ln -s (pwd)/nvim ~/.config/nvim
```

#### Plugins
Install [Vim Plug](https://github.com/junegunn/vim-plug). Vim Plug should install itself when you open nvim for the first time.
```
# Now open Vim and Vim Plug should attempt to install the plugins
nvim +PlugInstall
```

### Symlinking
```
# Fonts required for tpayne.zsh-theme
ln -s (pwd)/fonts ~/.fonts

# scripts
ln -s (pwd)/scripts/* ~/.local/bin

# config
ln -s (pwd)/config/tmux.conf ~/.tmux.conf
ln -s (pwd)/config/gitconfig ~/.gitconfig
ln -s (pwd)/config/tern-config ~/.tern-config

# Git config uses diff-so-fancy
brew install diff-so-fancy
# OR
curl -s -l https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy -o ~/.local/bin/diff-so-fancy
chmod +x ~/.local/bin/diff-so-fancy
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

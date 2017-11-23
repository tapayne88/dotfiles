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

### Vim
We're only interested in > Vim 8
```
brew install vim
```

#### Vim Symlinks
```
ln -s (pwd)/vim ~/.vim
ln -s (pwd)/vim/vimrc ~/.vimrc
```

#### Vim Plugins
Install [Vim Plug](https://github.com/junegunn/vim-plug)
```
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Now open Vim and Vim Plug should attempt to install the plugins
vim +PlugInstall
```

### Symlinking
```
# Fonts required for tpayne.zsh-theme
ln -s (pwd)/fonts ~/.fonts

ln -s (pwd)/tmux/tmux.conf ~/.tmux.conf
ln -s (pwd)/tmux/tmwork.sh ~/.local/bin/tmwork

ln -s (pwd)/misc/gitconfig ~/.gitconfig

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

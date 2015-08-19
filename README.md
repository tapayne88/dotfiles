# Dotfiles

Get em while they're hot!

#### Vim
#####[From source](https://gist.github.com/1348303)
```
hg clone https://vim.googlecode.com/hg/ vim
cd vim

# Build with python 2.7 (path on Xubuntu was '/usr/lib/python2.7/config')
# Found when installing Powerline (combination of CommandT configure and python path)
./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp \
--with-python-config-dir=/path/to/python/config --prefix=$HOME

make
make test (optional)
sudo make install
```

#####Alternatively
```
brew install vim
```

##### Vim Symlinks
```
ln -s `pwd`/vim ~/.vim
ln -s `pwd`/vim/vimrc ~/.vimrc
```


##### Vim Plugins
Install [NeoBundle](https://github.com/Shougo/neobundle.vim)
```
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
# Now open Vim and NeoBundle should attempt to install the plugins
```


#### ZSH
```
ln -s `pwd`/zsh/zshrc ~/.zshrc
ln -s `pwd`/zsh/config/* ~/.config/zsh/
ln -s `pwd`/zsh/themes/* ~/.oh-my-zsh/themes/

# Will probably need to create the custom plugins directory
mkdir ~/.oh-my-zsh/custom/plugins
ln -s `pwd`/zsh/plugins/* ~/.oh-my-zsh/custom/plugins/

# Fonts required for tpayne.zsh-theme
ln -s `pwd`/fonts ~/.fonts

ln -s `pwd`/misc/tmux.conf ~/.tmux.conf
ln -s `pwd`/misc/gitconfig ~/.gitconfig
ln -s `pwd`/misc/terminalrc ~/.config/Terminal/
```

#### Debian
Clone and run install.sh from:
```
git clone https://github.com/Anthony25/gnome-terminal-colors-solarized
```

#### OSX
##### iTerm2
Keybindings
```
# Set iTerm2 to switch tmux windows with Cmd+{ and Cmd+}
0x02 0x6E   Cmd + }			next window
0x02 0x70   Cmd + {			previous window

^[ b		Alt + <-		previous word
^[ f		Alt + ->		next word
```

##### General
- Install [Homebrew](http://brew.sh/)
- Install utilities
- Replace BSD tools with GNU [here](https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/)

Some brew modules you may want:
```
awscli
brew-cask
cmake
colordiff
coreutils
flow
fpp
gdbm
git
gnupg
gti
htop-osx
jmeter
keybase
libevent
maven
mobile-shell
mongodb
node
nvm
openssl
pcre
pkg-config
postgresql
protobuf
readline
squid2
tmux
vim
watch
zsh
```

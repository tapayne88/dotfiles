# Basic environment settings related to the zsh compiliation (not private)
#
# XDG Base Directory Specification
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
#export XDG_CACHE_HOME="$HOME/.cache"
#export ZSH_CACHE="$XDG_CACHE_HOME/zsh"
#mkdir -p $ZSH_CACHE
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"

# executable search path
# including Android SDK
paths=$HOME/.local/bin
paths+=:$HOME/.local/sbin
paths+=:$HOME/dev/android-sdk-linux/tools
paths+=:$HOME/dev/android-sdk-linux/platform-tools

export PATH=$paths:$PATH

export VISUAL=$HOME/.local/bin/vim
export EDITOR=$HOME/.local/bin/vim
export TERM=xterm-color

if [ -L ~/.dir_colors ]; then
    eval `dircolors $HOME/.dir_colors`
fi

node=`which node`

if [ $node != "node not found" ]; then
    export NODE_PATH=$node
fi

if [ -f /usr/local/bin/virtualenvwrapper ]; then
    export WORKON_HOME=~/python
    source /usr/local/bin/virtualenvwrapper.sh
fi

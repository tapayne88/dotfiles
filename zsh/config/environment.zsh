# Basic environment settings related to the zsh compiliation (not private)
#
# XDG Base Directory Specification
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"

# executable search path
paths=$HOME/.local/bin
paths+=:$HOME/.local/sbin
paths+=:/usr/local/bin

export PATH=$paths:$PATH

export VISUAL=vim
export EDITOR=vim
export TERM=xterm-256color

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

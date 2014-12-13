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
export BREW_PATH=`command -v brew`

# Replaces BSD standard commands with GNU
if test $BREW_PATH; then
    COREUTILS_PATH="$(brew --prefix coreutils)/libexec/gnubin"
    if [ -d $COREUTILS_PATH ]; then
        export HAS_BREW_COREUTILS=true
        export PATH=$(brew --prefix coreutils)/libexec/gnubin:$PATH
    fi
fi

export VISUAL=vim
export EDITOR=vim
export TERM=xterm-256color

if [ -L ~/.dir_colors ]; then
    eval `dircolors $HOME/.dir_colors`
fi

NODE_PATH=`command -v node`

if test $NODE_PATH; then
    export NODE_PATH=$NODE_PATH
fi

if [ -f /usr/local/bin/virtualenvwrapper ]; then
    export WORKON_HOME=~/python
    source /usr/local/bin/virtualenvwrapper.sh
fi

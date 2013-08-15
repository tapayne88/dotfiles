#!/bin/bash
# Add -x to line above for debug mode
# Prior to running:
#   - Install git
#   - Install zsh
#   - Install oh-my-zsh
#   - Clone github repos
#   - Compile and build vim from source
#   - Compile and build tmux from source

PWD=$(pwd)

function usage {
    echo "Usage: sudo $0 [option] command"
    echo "See help with -h"
}

function printHelp {
    echo "HELP"
    echo "Usage: sudo $0 [option] command"
    echo "Options:"
    echo "  -h  help"
    echo "Commands:"
    echo "  zsh - install and configure zsh"
    echo "  vim - install and configure vim"
    echo "  tmux - install and configure tmux"
    echo "  all - install and configure everything"
}

function installMercurial {
    echo "Installing mercurial..."
    if [ ! -d "$HOME/mercurial" ]; then
        $(mkdir $HOME/mercurial)
    fi
    $(sudo apt-get -y install mercurial) &> /dev/null
}

function installGit {
    echo "Installing git..."
    if [ ! -d "$HOME/git" ]; then
        $(mkdir $HOME/git)
    fi
    $(sudo apt-get -y install git) &> /dev/null
    $(ln -s "$PWD/gitconfig" $HOME/.gitconfig)
}

function installZsh {
    echo "Installing ZSH..."
    $(sudo apt-get -y install zsh) &> /dev/null
}

function upgrade_oh_my_zsh {
    $(/usr/bin/env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh)
}


function installOhMyZsh {
    echo "Installing Oh-My-Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        $(sudo apt-get -y install curl) &> /dev/null
        $(curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh)
    else
        upgrade_oh_my_zsh
    fi
}

function configureZsh {
    echo "Configuring ZSH..."
    $(mkdir -p $HOME/.config/zsh)
    $(mkdir -p $HOME/.oh-my-zsh/custom/plugins)

    $(ln -s "$PWD/zsh/zshrc" $HOME/.zshrc)
    $(ln -s "$PWD/zsh/zshrc_home" $HOME/.zshrc_home)
    $(ln -s "$PWD/zsh/zshrc_work" $HOME/.zshrc_work)
    for file in $(ls "$PWD/zsh/config"); do
        $(ln -s "$PWD/zsh/config/$file" $HOME/.config/zsh/)
    done
    for file in $(ls "$PWD/zsh/themes"); do
        $(ln -s "$PWD/zsh/themes/$file" $HOME/.oh-my-zsh/themes/)
    done
    for file in $(ls "$PWD/zsh/plugins"); do
        $(ln -s "$PWD/zsh/plugins/$file" $HOME/.oh-my-zsh/custom/plugins/)
    done
}

function installVim {
    echo "Installing VIM..."
    $(cd "$HOME/mercurial")
    $(sudo apt-get -y install ruby ruby-dev libncurses5-dev mercurial build-essential rake) &> /dev/null
    $(hg clone https://vim.googlecode.com/hg/ vim-code)
    $(cd vim-code)
    $(./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --with-python-config-dir=/path/to/python/config --prefix=$HOME/.local)
    $(make && sudo make install)
}

function configureVim {
    echo "Configuring VIM..."
    $(ln -s "$PWD/vim" $HOME/.vim)
    $(ln -s "$PWD/vim/vimrc" $HOME/.vimrc)
    $(ln -s "$PWD/powerline" $HOME/.config/)
    $(ln -s "$PWD/vim/bundle/pathogen/autoload/pathogen.vim" "$PWD/vim/autoload/")
}

function installTmux {
    echo "Installing Tmux..."
    $(cd "$HOME/git")
    $(sudo apt-get -y install libncurses5-dev build-essential) &> /dev/null
    $(git clone git://git.code.sf.net/p/tmux/tmux-code tmux-code)
    $(cd tmux-code)
    $(sh autogen.sh)
    $(./configure && make && sudo make install)
    $(ln -s "$PWD/tmux/tmux.conf" $HOME/.tmux.conf)
}

function optionalConfig {
    echo "Configuring optional links..."
    $(ln -s "$PWD/fonts" $HOME/.fonts)
    $(ln -s "$PWD/inputrc" $HOME/.inputrc)
    $(ln -s "$PWD/editrc" $HOME/.editrc)
    if [ ! -d "$HOME/.config/Terminal" ]; then
        $(mkdir -p $HOME/.config/Terminal)
    fi
    $(ln -s "$PWD/terminalrc" $HOME/.config/Terminal/)
}

function cloneMyRepos {
    echo "Cloning my other repos..."
    $(cd "$HOME/git")
    if [ ! -d scripts ]; then
        $(git clone https://github.com/tapayne88/scripts)
    else
        $(cd scripts)
        $(git pull)
        #$(./setup.sh)
    fi
    if [ ! -d colour_schemes ]; then
        $(git clone https://github.com/tapayne88/colour_schemes)
    else
        $(cd colour_schemes)
        $(git pull)
        #$(./setup.sh)
    fi
}

function runAll {
    echo "Running all..."
    installMercurial
    installGit
    #ZSH
    installZsh
    installOhMyZsh
    configureZsh
    # VIM
    installVim
    configureVim
    # TMUX
    installTmux
    optionalConfig
    cloneMyRepos
}

while getopts "h" OPTION; do
    case $OPTION in
        h)
            printHelp
            exit
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [ "$(whoami)" != "root" ]; then
    usage
    exit
fi

echo "The repo structure has changed since this script was written, so... quiting!"
exit

if [ "$1" = "" ]; then
    echo "Do you want to run the whole script? (y/n)"
    read ANS

    # does not work if conditions say != and actions swapped - do not know why
    if [ "$ANS" = "y" ] || [ "$ANS" = "Y" ] ;  then
        echo "running"
        runAll
        exit
    else
        echo "not running"
        usage
        exit
    fi
else
    case $1 in
        zsh)
            installZsh
            installOhMyZsh
            configureZsh
            exit
            ;;
        vim)
            installVim
            configureVim
            exit
            ;;
        tmux)
            installTmux
            configureTmux
            exit
            ;;
        all)
            runAll
            exit
            ;;
        ?)
            usage
            exit
            ;;
    esac
fi

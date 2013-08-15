Dotfiles, get em while they're hot!

Installation:

        VIM (from https://gist.github.com/1348303)
        hg clone https://vim.googlecode.com/hg/ vim
        cd vim

        # Used to configure vim (found when install CommandT)
        ./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp --prefix=$HOME

        # Build with python 2.7 (path on Xubuntu was '/usr/lib/python2.7/config')
        # Found when installing Powerline (combination of CommandT configure and python path)
        ./configure --with-features=huge --enable-rubyinterp --enable-pythoninterp \
        --with-python-config-dir=/path/to/python/config --prefix=$HOME

        make
        make test (optional)
        sudo make install

        # Install Vundle and VIM Plugins
        git clone https://github.com/gmarik/vundle.git ~/git/vundle
        ln -s ~/git/vundle ~/git/dotfiles/vim/bundle
        vim +BundleInstall +qall

        Config:
        # Bash
        ln -s bashrc ~/.bashrc
        ln -s bashrc_work ~/.bashrc_work
        ln -s bashrc_home ~/.bashrc_home

        # ZSH
        ln -s zsh/zshrc ~/.zshrc
            OR
        ln -s zsh/zshrc_mac ~/.zshrc

        ln -s zsh/zshrc_home ~/.zshrc_home
        ln -s zsh/zshrc_work ~/.zshrc_work
        ln -s zsh/config/* ~/.config/zsh/
        ln -s zsh/themes/* ~/.oh-my-zsh/themes/
        # Will probably need to create the custom plugins directory
        mkdir ~/.oh-my-zsh/custom/plugins
        ln -s zsh/plugins/* ~/.oh-my-zsh/custom/plugins/

        # Fonts required for tpayne.zsh-theme
        ln -s fonts ~/.fonts

        ln -s inputrc ~/.inputrc
        ln -s editrc ~/.editrc

        ln -s tmux.conf ~/.tmux.conf
        ln -s gitconfig ~/.gitconfig

        ln -s vim ~/.vim
        ln -s vim/vimrc ~/.vimrc 
        ln -s terminalrc ~/.config/Terminal/

        git submodule init
        git submodule update

        cd vim/bundle/command-t
        rake make

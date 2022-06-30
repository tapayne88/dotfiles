{ pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    antigen # zsh plugin manager
    asciinema # asciinema.org recorder
    awscli2 # cli for working with aws
    bat # colourised cat
    cargo # rust build tool for tmux-thumbs
    chezmoi # dotfile manager
    ctop # container top process tool
    curl # curl...
    delta # better git diffs
    duf # pretty alternative to df
    exa # ls replacement
    fd # faster more user friendly find
    fpp # facebook picker
    fzf # fuzzy-finder
    gawk # gnu awk
    gnupg # gnu pretty good privacy
    gti # alias for git, with a gti
    htop # pretty top
    inetutils # network utils, like traceroute, etc.
    jq # json cli processor
    kubectx # nicer interaction with k8s cli
    mosh # better ssh
    ncdu # disk usage tool
    netcat # netcat implementaion
    nodejs # nodejs...
    poppler_utils # pdf utils - pdfunite to combine pdfs
    python3 # python38
    python38Packages.pip # pip for python38
    ripgrep # rg searching
    silver-searcher # ag searching
    neofetch # pretty print of system info
    openssh # ssh et al.
    ruby # always useful to have ruby
    tmuxp # declaritive tmux session launcher
    tree # print directory structure
    up # utlimate plumber - unix pipes tool
    unixtools.watch # run command periodically
    vim # vim
    watchman # watch files and run command on change
    wget # fetch things from urls
    yarn # JS package manager
    zsh # shell

    # Unstable Packages
    unstable._1password # 1password version is quite old - unstable is much newer
    unstable.git # newest git!
    unstable.tldr # simplified and community-driven man pages
    unstable.tmux # terminal multiplexer
  ];
}

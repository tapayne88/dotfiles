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
    dig # dns lookup
    duf # pretty alternative to df
    eza # ls replacement
    fd # faster more user friendly find
    fpp # facebook picker
    fzf # fuzzy-finder
    gawk # gnu awk
    glow # markdown on the CLI, with pizzazz!
    gnupg # gnu pretty good privacy
    gti # alias for git, with a gti
    htop # pretty top
    inetutils # network utils, like traceroute, etc.
    iperf # Tool to measure IP bandwidth using UDP or TCP
    just # Handy way to save and run project-specific commands
    jq # json cli processor
    kubie # even nicer interaction with k8s cli with multiple configs
    mosh # better ssh
    netcat # netcat implementaion
    nodejs # nodejs...
    poppler_utils # pdf utils - pdfunite to combine pdfs
    python3 # python312
    python312Packages.pip # pip for python312
    python312Packages.setuptools # setuptools for python312
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
    wget # fetch things from urls
    xan # fast CSV toolkit
    yarn # JS package manager
    yq # yaml cli processor (needs jq)
    zsh # shell

    # Unstable Packages
    unstable._1password-cli # 1password version is quite old - unstable is much newer
    unstable.git # newest git!
    unstable.git-town # Generic, high-level git support for git-flow workflows
    unstable.hurl # HTTP requests runner
    unstable.jqp # TUI playground for jq
    unstable.nerdfix # fix for nerd fonts
    unstable.tldr # simplified and community-driven man pages
    unstable.tmux # terminal multiplexer
    unstable.wttrbar # module for showing the weather
  ];
}

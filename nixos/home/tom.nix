{ config, pkgs, ... }:

{
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };
  programs.tmux.enable = true;

  home.packages = with pkgs; [
    antigen # zsh plugin manager
    atuin # Magical shell history
    bat # colourised cat
    eza # ls replacement
    fd # faster more user friendly find
    fzf # fuzzy-finder
    gti # alias for git, with a gti
    jq # json cli processor
    ripgrep # rg searching
    vivid # A themeable LS_COLORS generator with a rich filetype datebase
    zoxide # A smarter cd command

    # unstable
    carapace # A multi-shell completion library
    git # newest git!
    jqp # TUI playground for jq
    k9s # Kubernetes CLI To Manage Your Clusters In Style!
    kubie # even nicer interaction with k8s cli with multiple configs
    lazygit # simple terminal UI for git commands
    television # A very fast, portable and hackable fuzzy finder.
  ];

  home.stateVersion = "25.05";
}

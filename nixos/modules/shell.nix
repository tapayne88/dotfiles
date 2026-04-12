{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;

    # TODO: Fix deprecation warning
    dotDir = ".config/zsh";

    initContent = ''
      source ${pkgs.antigen}/share/antigen/antigen.zsh

      if [ -f ~/.zshrc ]; then
        source ~/.zshrc
      fi
    '';
  };

  home.packages = with pkgs; [
    antigen # zsh plugin manager
    atuin # Magical shell history
    bat # colourised cat
    delta # better git diffs
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
    tmux # terminal multiplexer
  ];
}

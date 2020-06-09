{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";

  # Fix I/O error with XML write - root cause unknown
  xdg.mime.enable = false;

  home.packages = with pkgs; [
    _1password
    antigen
    bat
    chezmoi
    fpp
    fzf
    gitAndTools.diff-so-fancy
    git
    jq
    neovim
    nix-zsh-completions
    openssh
    silver-searcher
    tmux
    tmuxp
    vim
    zsh
    zsh-completions
  ];
}

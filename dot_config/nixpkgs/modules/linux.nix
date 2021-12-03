{ pkgs, ... }:
{
  # Fix I/O error with XML write - root cause unknown
  xdg.mime.enable = false;

  home.packages = with pkgs; [
    gcc # neovim - building nvim-treesitter parsers
    nq  # linux queue utility
  ];
}

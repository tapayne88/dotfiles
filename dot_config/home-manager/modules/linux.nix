{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc # neovim - building nvim-treesitter parsers
    gnumake # neovim treesitter
    nq # linux queue utility
    unzip # wsl doesn't include unzip
  ];
}

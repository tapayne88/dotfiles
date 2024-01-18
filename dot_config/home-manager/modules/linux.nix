{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc # neovim - building nvim-treesitter parsers
    gnumake # neovim treesitter
    nq # linux queue utility
    unzip # wsl doesn't include unzip

    # MacOS installed through homebrew as needs to be in /usr/local/bin for some reason
    # https://github.com/facebook/watchman/issues/923#issuecomment-1506301844
    watchman # watch files and run command on change
  ];
}

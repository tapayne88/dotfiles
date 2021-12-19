{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: Move back to home.nix when no longer at SBG - see flake.nix todo
    openssh
    unstable.git

    gcc # neovim - building nvim-treesitter parsers
    nq # linux queue utility
  ];
}

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: Remove when no longer at SBG - see flake.nix todo
    old.openssh
    old.git

    coreutils   # gnu utilities
    gnugrep     # gnu grep
    gnused      # gnu sed
  ];
}

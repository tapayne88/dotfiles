{ pkgs, ... }:
{
  home.packages = with pkgs; [
    binutils
    gcc
    ncdu # disk usage tool
    nq # linux queue utility
    unzip
  ];
}

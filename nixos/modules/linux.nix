{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ncdu # disk usage tool
    nq # linux queue utility
    unzip
  ];
}

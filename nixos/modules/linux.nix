{ pkgs, ... }:
{
  home.packages = with pkgs; [
    binutils
    gcc
    ncdu # disk usage tool
    nq # linux queue utility
    unzip
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };
}

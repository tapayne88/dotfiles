{ pkgs, ... }:
{
  home.packages = with pkgs; [
    adoptopenjdk-hotspot-bin-13 # jvm
  ];
}

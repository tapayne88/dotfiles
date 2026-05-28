{
  pkgs,
  ...
}:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
      tumbler
    ];
  };
}

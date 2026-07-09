{
  flake.homeModules.darwin =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        coreutils # gnu utilities
        gnugrep # gnu grep
        gnused # gnu sed
      ];
    };
}

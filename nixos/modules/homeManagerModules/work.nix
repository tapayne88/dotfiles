{
  flake.homeModules.work =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hub # github cli tool
        terraform
      ];
    };
}

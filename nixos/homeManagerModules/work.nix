{
  flake.modules.homeManager.work =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hub # github cli tool
        terraform
      ];
    };
}

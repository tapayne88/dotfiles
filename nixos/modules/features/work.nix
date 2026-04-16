{ self, inputs, ... }:
{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hub # github cli tool
        mysql80
        terraform
      ];
    };
}

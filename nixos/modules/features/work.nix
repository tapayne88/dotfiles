{ self, inputs, ... }:
{
  nixpkgs.allowedUnfreePackages = [ "terraform" ];

  flake.modules.homeManager.work =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        hub # github cli tool
        mysql80
        terraform
      ];
    };
}

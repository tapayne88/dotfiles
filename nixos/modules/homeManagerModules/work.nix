{
  flake.homeModules.work =
    { pkgs, ... }:
    {
      allowedUnfreePackages = [ "terraform" ];

      home.packages = with pkgs; [
        hub # github cli tool
        terraform
      ];
    };
}

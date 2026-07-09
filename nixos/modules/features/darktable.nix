{
  flake.nixosModules.darktable =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
      };

      environment.systemPackages = with pkgs; [
        darktable
      ];
    };
}

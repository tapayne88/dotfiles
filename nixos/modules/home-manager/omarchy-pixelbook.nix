{ self, inputs, ... }:
{
  # Pixelbook Omarchy
  flake.homeConfigurations."tpayne@omarchy-pixelbook" =
    inputs.home-manager.lib.homeManagerConfiguration
      {
        pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
        modules = [
          {
            imports = [
              self.nixosModules.nixpkgsConfig
              self.nixosModules.shell
              self.nixosModules.linux
              self.nixosModules.neovim
            ];
          }
          {
            home = {
              username = "tpayne";
              homeDirectory = "/home/tpayne";
              stateVersion = "25.11";
            };
          }
        ];
      };
}

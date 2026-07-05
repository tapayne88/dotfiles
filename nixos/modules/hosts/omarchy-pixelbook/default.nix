{ self, inputs, ... }: {
  # Pixelbook Omarchy
  flake.homeConfigurations."tpayne@omarchy-pixelbook" =
    inputs.home-manager.lib.homeManagerConfiguration
      {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          {
            imports = [
              # ./configs/nixpkgs.nix
              self.homeModules.shell
              self.homeModules.linux
              self.homeModules.neovim
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

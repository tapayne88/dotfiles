{ self, inputs, ... }: {
  # Pixelbook Omarchy
  flake.homeConfigurations."tpayne@omarchy-pixelbook" =
    inputs.home-manager.lib.homeManagerConfiguration
      {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          self.homeModules.unfree

          self.homeModules.linux
          self.homeModules.neovim
          self.homeModules.nh
          self.homeModules.shell
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

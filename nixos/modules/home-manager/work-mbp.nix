{ self, inputs, ... }:
{
  # MacBook Pro M3 (Work)
  flake.homeConfigurations."tom.payne@KL2M3W1G4N" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
    modules = [
      {
        imports = [
          self.nixosModules.nixpkgsConfig
          self.nixosModules.shell
          self.nixosModules.darwin
          self.nixosModules.neovim
          self.nixosModules.work
        ];
      }
      {
        home = {
          username = "tom.payne";
          homeDirectory = "/Users/tom.payne";
          stateVersion = "25.11";
        };
      }
    ];
  };
}

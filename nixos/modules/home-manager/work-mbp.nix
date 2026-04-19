{ self, inputs, ... }:
{
  # MacBook Pro M3 (Work)
  flake.homeConfigurations."tom.payne@KL2M3W1G4N" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
    modules = [
      {
        imports = [
          self.modules.homeManager.shell
          self.modules.homeManager.darwin
          self.modules.homeManager.neovim
          self.modules.homeManager.work
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

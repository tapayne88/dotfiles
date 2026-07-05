{ self, inputs, ... }: {
  # MacBook Pro M3 (Work)
  flake.homeConfigurations."tom.payne@KL2M3W1G4N" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-darwin;
    extraSpecialArgs = {
      pkgs-unstable = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    };
    modules = [
      {
        imports = [
          self.homeModules.shell
          self.homeModules.darwin
          self.homeModules.neovim
          self.homeModules.work
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

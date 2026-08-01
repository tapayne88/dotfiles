{ self, inputs, ... }: {
  # MacBook Pro M3 (Work)
  flake.homeConfigurations."tom.payne@KL2M3W1G4N" =
    inputs.home-manager-stable.lib.homeManagerConfiguration
      {
        pkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {
          pkgs-unstable = import inputs.nixpkgs {
            system = "aarch64-darwin";
            config.allowUnfree = true;
          };
        };
        modules = [
          self.homeModules.unfree
          self.homeModules.host-settings

          self.homeModules.darwin
          self.homeModules.neovim
          self.homeModules.nh
          self.homeModules.shell
          self.homeModules.work
          {
            home = {
              username = "tom.payne";
              homeDirectory = "/Users/tom.payne";
              stateVersion = "25.11";
            };
          }
          {
            hostSettings.sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzWdfY+aZo47dJrD9Q4OI5h9fM+3Dkp9GiaVhV4l5ce";
          }
        ];
      };
}

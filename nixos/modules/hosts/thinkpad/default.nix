{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      }

      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.default
      inputs.impermanence.nixosModules.impermanence

      # Nix Config
      self.nixosModules.host-settings
      self.nixosModules.unfree
      self.nixosModules.thinkpadConfiguration

      # Features
      self.nixosModules.default
    ];
  };
}

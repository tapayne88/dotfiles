{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = self.nixpkgs-unstable.lib.nixosSystem {
    modules = [
      self.nixosModules.nixpkgsConfig
      self.nixosModules.thinkpadConfiguration
      self.nixosModules.home.tom
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };
}

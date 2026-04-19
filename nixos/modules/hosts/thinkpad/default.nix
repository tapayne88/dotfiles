{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.thinkpadConfiguration
      self.nixosModules.tom
      inputs.home-manager.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];
  };
}

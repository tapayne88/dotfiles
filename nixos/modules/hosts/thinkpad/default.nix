{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.default
      inputs.impermanence.nixosModules.impermanence
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x230

      # Nix Config
      self.nixosModules.nix-settings
      self.nixosModules.host-settings
      self.nixosModules.unfree
      self.nixosModules.thinkpadConfiguration

      # Features
      self.nixosModules.default
    ];
  };
}

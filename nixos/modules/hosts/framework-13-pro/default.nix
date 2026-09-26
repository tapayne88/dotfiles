{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations."framework-13-pro" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.stylix.nixosModules.stylix
      inputs.home-manager.nixosModules.default
      inputs.impermanence.nixosModules.impermanence
      inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3

      # Nix Config
      self.nixosModules.nix-settings
      self.nixosModules.host-settings
      self.nixosModules.unfree
      self.nixosModules.framework13ProConfiguration

      # Features
      self.nixosModules.default
    ];
  };
}

{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
    };

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

      # ../../configs/host-options.nix
      # ../../configs/nixpkgs.nix
      self.modules.nixos.default
      self.modules.nixos.thinkpadConfiguration
    ];
  };
}

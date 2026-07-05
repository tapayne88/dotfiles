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
      self.modules.nixos.audio
      self.modules.nixos.darktable
      self.modules.nixos.file-browser
      self.modules.nixos.file-syncing
      self.modules.nixos.greeter
      self.modules.nixos.home-manager
      self.modules.nixos.network-shares
      self.modules.nixos.tailscale
      self.modules.nixos.password-manager
      self.modules.nixos.printing
      self.modules.nixos.programs
      self.modules.nixos.stylix
      self.modules.nixos.user
      self.modules.nixos.window-manager
      self.modules.nixos.thinkpadConfiguration
    ];
  };
}

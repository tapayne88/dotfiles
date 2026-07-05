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

      # Features
      self.nixosModules.audio
      self.nixosModules.darktable
      self.nixosModules.file-browser
      self.nixosModules.file-syncing
      self.nixosModules.greeter
      self.nixosModules.home-manager
      self.nixosModules.network-shares
      self.nixosModules.tailscale
      self.nixosModules.password-manager
      self.nixosModules.printing
      self.nixosModules.programs
      self.nixosModules.stylix
      self.nixosModules.user
      self.nixosModules.window-manager
      self.nixosModules.thinkpadConfiguration
    ];
  };
}

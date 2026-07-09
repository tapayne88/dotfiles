{ self, ... }:
{
  flake.nixosModules.default = {
    imports = [
      self.nixosModules.audio
      self.nixosModules.darktable
      self.nixosModules.file-browser
      self.nixosModules.file-syncing
      self.nixosModules.greeter
      self.nixosModules.home-manager
      self.nixosModules.impermanence
      self.nixosModules.network
      self.nixosModules.network-shares
      self.nixosModules.password-manager
      self.nixosModules.printing
      self.nixosModules.programs
      self.nixosModules.stylix
      self.nixosModules.user
      self.nixosModules.vpn
      self.nixosModules.window-manager
    ];
  };
}

{ self, ... }:
{
  flake.modules.nixos.default = {
    imports = [
      self.nixos.audio
      self.nixos.darktable
      self.nixos.file-browser
      self.nixos.file-syncing
      self.nixos.greeter
      self.nixos.home-manager
      self.nixos.network-shares
      self.nixos.tailscale
      self.nixos.password-manager
      self.nixos.printing
      self.nixos.programs
      self.nixos.stylix
      self.nixos.user
      self.nixos.window-manager
    ];
  };
}

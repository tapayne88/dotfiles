{ self, ... }:
{
  flake.modules.nixos.default = {
    imports = [
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
    ];
  };
}

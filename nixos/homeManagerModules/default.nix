{ self, ... }:
{
  flake.modules.homeManager.default = {
    imports = [
      self.homeManager.neovim
      self.homeManager.shell
      self.homeManager.linux
      self.homeManager.browser
      self.homeManager.hyprland
      self.homeManager.obsidian
      self.homeManager.programs
      self.homeManager.vicinae
    ];
  };
}

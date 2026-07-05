{ self, ... }:
{
  flake.modules.homeManager.default = {
    imports = [
      self.modules.homeManager.neovim
      self.modules.homeManager.shell
      self.modules.homeManager.linux
      self.modules.homeManager.browser
      self.modules.homeManager.hyprland
      self.modules.homeManager.obsidian
      self.modules.homeManager.programs
      self.modules.homeManager.vicinae
    ];
  };
}

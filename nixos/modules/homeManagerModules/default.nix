{ self, ... }:
{
  flake.homeModules.default = {
    imports = [
      self.homeModules.browser
      self.homeModules.linux
      self.homeModules.neovim
      self.homeModules.obsidian
      self.homeModules.programs
      self.homeModules.shell
      self.homeModules.vicinae
    ];
  };
}

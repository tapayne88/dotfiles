{ self, inputs, ... }:
{
  flake.nixosModules.tom = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.tom = {
        imports = [
          self.modules.homeManager.neovim
          self.modules.homeManager.shell
          self.modules.homeManager.linux
        ];
        home = {
          username = "tom";
          homeDirectory = "/home/tom";
          stateVersion = "25.11";
        };
      };
    };
  };
}

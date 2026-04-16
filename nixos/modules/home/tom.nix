{ self, inputs, ... }:

{
  flake.nixosModules.home.tom = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.tom = {
        imports = [
          self.nixosModules.neovim
          self.nixosModules.shell
          self.nixosModules.linux
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

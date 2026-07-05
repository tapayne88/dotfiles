{ self, inputs, ... }:
{
  flake.modules.nixos.home-manager =
    { config, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
        };
        users."${config.hostSettings.username}" = {
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
          home = {
            username = config.hostSettings.username;
            homeDirectory = "/home/${config.hostSettings.username}";
            stateVersion = "25.11";
          };
        };
      };
    };
}

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
            self.homeManager.default
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

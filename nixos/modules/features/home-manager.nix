{ self, inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.nixosModules.home-manager =
    { config, ... }:
    {
      environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
        "/home"
      ];

      home-manager = {
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
        };
        users."${config.hostSettings.username}" = {
          imports = [
            self.homeModules.unfree

            self.homeModules.browser
            self.homeModules.linux
            self.homeModules.neovim
            self.homeModules.notes
            self.homeModules.programs
            self.homeModules.shell
            self.homeModules.window-manager
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

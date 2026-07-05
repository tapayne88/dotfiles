{ self, inputs, ... }:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake.nixosModules.home-manager =
    { config, ... }:
    {
      home-manager = {
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs;
        };
        users."${config.hostSettings.username}" = {
          imports = [
            self.homeModules.unfree

            self.homeModules.neovim
            self.homeModules.shell
            self.homeModules.linux
            self.homeModules.browser
            self.homeModules.obsidian
            self.homeModules.programs
            self.homeModules.vicinae

            self.homeModules.hyprland
            self.homeModules.hypridle
            self.homeModules.hyprlandConfig
            self.homeModules.hyprlock
            self.homeModules.waybar
            self.homeModules.wlogout
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

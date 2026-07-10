{ self, ... }:
{
  flake.homeModules.window-manager = {
    imports = [
      self.homeModules.hypridle
      self.homeModules.hyprland
      self.homeModules.hyprlock
      self.homeModules.waybar
      self.homeModules.wlogout

      self.homeModules.noctalia
    ];

    services.mako.enable = true;
    services.hyprpolkitagent.enable = true;
  };

  flake.nixosModules.window-manager = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.uwsm.enable = true;

    programs.waybar.enable = true;
  };
}

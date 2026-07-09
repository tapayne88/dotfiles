{ self, ... }:
{
  flake.homeModules.hyprland = {
    imports = [
      self.homeModules.hypridle
      self.homeModules.hyprlandConfig
      self.homeModules.hyprlock
      self.homeModules.waybar
      self.homeModules.wlogout
    ];

    services.mako.enable = true;
    services.hyprpolkitagent.enable = true;
  };
}

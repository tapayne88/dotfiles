{
  self,
  ...
}:
{
  flake.modules.homeManager.hyprland = {
    imports = [
      self.homeManager.hypridle
      self.homeManager.hyprlandConfig
      self.homeManager.hyprlock
      self.homeManager.waybar
      self.homeManager.wlogout
    ];

    services.mako.enable = true;
    services.hyprpolkitagent.enable = true;
  };
}

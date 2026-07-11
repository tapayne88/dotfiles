{ self, ... }:
{
  flake.homeModules.window-manager = {
    imports = [
      self.homeModules.hyprland

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
  };
}

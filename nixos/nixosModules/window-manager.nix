{
  flake.modules.nixos.window-manager = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.uwsm.enable = true;

    programs.waybar.enable = true;
  };
}

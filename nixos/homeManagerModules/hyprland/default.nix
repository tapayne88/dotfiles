{
  imports = [
    ./hypridle.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./waybar.nix
    ./wlogout.nix
  ];

  services.mako.enable = true;
  services.hyprpolkitagent.enable = true;
}

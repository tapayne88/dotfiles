{ inputs, ... }:
{
  flake.nixosModules.greeter =
    { pkgs, config, ... }:
    {
      imports = [
        inputs.noctalia-greeter.nixosModules.default
      ];

      programs.noctalia-greeter = {
        enable = true;

        # Optional configuration
        greeter-args = "--user ${config.hostSettings.username} --cmd 'uwsm start hyprland-uwsm.desktop'";
        settings = {
          theme = "catppuccin";
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
        };
      };
    };
}

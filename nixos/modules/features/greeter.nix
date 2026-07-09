{ inputs, ... }:
{
  flake.nixosModules.greeter =
    {
      pkgs,
      config,
      ...
    }:
    let
      internalMonitor = config.hostSettings.internalMonitor;
    in
    {
      nix.settings = {
        extra-substituters = [ "https://nyx.cachix.org" ];
        extra-trusted-public-keys = [ "nyx.cachix.org-1:xH6G0MO9PrpeGe7mHBtj1WbNzmnXr7jId2mCiq6hipE=" ];
      };

      nixpkgs.overlays = [
        (final: prev: {
          tuigreet = inputs.tuigreet-fork.packages.${pkgs.stdenv.hostPlatform.system}.default;
        })
      ];

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            user = "greeter";
            command = "${pkgs.tuigreet}/bin/tuigreet --cmd 'uwsm start hyprland-uwsm.desktop'";
          };
        };
      };

      environment.etc."tuigreet/config.toml".text = ''
        [display]
        show_time = true

        [remember]
        username = true
        session = false
        user_session = true

        [user_menu]
        enabled = true
        min_uid = 1000
        max_uid = 60000

        [secret]
        mode = "characters" 
        characters = "*"

        [theme]
        border = "gray"
        container = "black"
        text = "gray"
        time = "green"
        prompt = "magenta"
        input = "gray"
        action = "darkgrey"
        button = "yellow"

        [[outputs]]
        connector = "HDMI-A-1"
        primary = true

        [[outputs]]
        connector = "${internalMonitor}"
        enabled = true
      '';
    };
}

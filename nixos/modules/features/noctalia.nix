{ inputs, ... }:
{
  flake.nixosModules.noctalia = {
    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
  };

  flake.homeModules.noctalia = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = false;

      settings = {
        launch_apps_as_systemd_services = true;

        bar = {
          main = {
            margin_ends = 20; # inset from each end of the bar along its main axis
            widget_spacing = 10; # gap between widgets within a section
            start = [
              "launcher"
              "workspaces"
            ];
            center = [ "clock" ];
            end = [
              "media"
              "caffeine"
              "tray"
              "sysmon"
              "weather"
              "notifications"
              "clipboard"
              "network"
              "volume"
              "battery"
              "control-center"
              "session"
            ];
          };
        };
        widget = {
          battery = {
            display_mode = "graphic";
            show_label = false;
          };
          media = {
            album_art_only = true;
            art_size = 24;
            hide_when_no_media = true;
          };
          network = {
            show_label = false;
          };
          volume = {
            show_label = false;
          };
          weather = {
            max_length = 180;
            show_condition = false;
            show_temperature = true;
          };
        };
        location = {
          auto_locate = true;
        };
        idle.behavior = {
          lock = {
            timeout = 300;
            action = "lock";
          };
          screen-off = {
            timeout = 600;
            action = "screen_off";
          };
          suspend = {
            timeout = 1800;
            action = "lock_and_suspend";
          };
        };
      };
    };
  };
}

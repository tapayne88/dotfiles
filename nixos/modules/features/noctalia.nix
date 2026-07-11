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

  flake.homeModules.noctalia = { osConfig, ... }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia = {
      enable = true;
      systemd.enable = false;

      settings = {
        shell = {
          launch_apps_as_systemd_services = true;
        };

        bar =
          let
            endWidgets = [
              "caffeine"
              "tray"
              "sysmon"
              "weather"
              "notifications"
              "clipboard"
              "network"
              "volume"
              "battery"
              "clock"
              "control-center"
              "session"
            ];
            shortWidgetVariants = [ "clock" ];
            getShortVariant = x: "${x}-short";
          in
          {
            main = {
              margin_ends = 20; # inset from each end of the bar along its main axis
              widget_spacing = 10; # gap between widgets within a section
              start = [
                "launcher"
                "workspaces"
              ];
              center = [ "media" ];
              end = endWidgets;
              monitor = {
                "${osConfig.hostSettings.internalMonitor}" = {
                  end = map (x: if builtins.elem x shortWidgetVariants then (getShortVariant x) else x) endWidgets;
                };
              };
            };
          };
        widget = {
          battery = {
            display_mode = "graphic";
            show_label = false;
          };
          clock = {
            format = "{:%H:%M %A, %e %B}";
            tooltip_format = "{:%A, %e %B %Y}";
          };
          clock-short = {
            type = "clock";
            format = "{:%H:%M}";
            tooltip_format = "{:%A, %e %B %Y}";
          };
          media = {
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

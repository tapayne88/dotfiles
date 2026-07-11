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
            start = [
              "launcher"
              "workspaces"
            ];
            center = [ "clock" ];
            end = [
              "media"
              "caffeine"
              "tray"
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
          network = {
            show_label = false;
          };
          media = {
            album_art_only = true;
            art_size = 24;
            hide_when_no_media = true;
          };
        };
        location = {
          auto_locate = true;
        };
      };
    };
  };
}

{
  flake.modules.homeManager.hypridle =
    {
      pkgs,
      lib,
      ...
    }:
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || ${lib.getExe pkgs.hyprlock}"; # avoid starting multiple hyprlock instances.
            before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
            after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
          };

          listener = [
            {
              timeout = 150; # 2.5min.
              on-timeout = "${lib.getExe pkgs.brightnessctl} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
              on-resume = "${lib.getExe pkgs.brightnessctl} -r"; # monitor backlight restore.
            }

            {
              timeout = 300; # 5min
              on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
            }

            {
              timeout = 330; # 5.5min
              on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; # screen on when activity is detected after timeout has fired.
            }

            {
              timeout = 1800; # 30min
              on-timeout = "systemctl suspend"; # suspend pc
            }
          ];
        };
      };
    };
}

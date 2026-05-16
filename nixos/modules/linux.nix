{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "Tom" ];
  };

  home.packages = with pkgs; [
    binutils
    gcc
    ncdu # disk usage tool
    nq # linux queue utility
    unzip
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "kitty.desktop" ];
    };
  };

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
        lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
        before_sleep_cmd = loginctl lock-session    # lock before suspend.
        after_sleep_cmd = hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
    }

    listener {
        timeout = 150                                                   # 2.5min.
        on-timeout = ${pkgs.brightnessctl}/bin/brightnessctl -s set 10  # set monitor backlight to minimum, avoid 0 on OLED monitor.
        on-resume = ${pkgs.brightnessctl}/bin/brightnessctl -r          # monitor backlight restore.
    }

    listener {
        timeout = 300                                 # 5min
        on-timeout = loginctl lock-session            # lock screen when timeout has passed
    }

    listener {
        timeout = 330                                                     # 5.5min
        on-timeout = hyprctl dispatch dpms off                            # screen off when timeout has passed
        on-resume = hyprctl dispatch dpms on && brightnessctl -r          # screen on when activity is detected after timeout has fired.
    }

    listener {
        timeout = 1800                                # 30min
        on-timeout = systemctl suspend                # suspend pc
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
        background-image: none;
        box-shadow: none;
    }

    window {
        background-color: rgba(30, 30, 46, 0.90);
    }

    button {
        border-radius: 0;
        border-color: #89b4fa;
        text-decoration-color: #cdd6f4;
        color: #cdd6f4;
        background-color: #181825;
        border-style: solid;
        border-width: 1px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
    }

    button:focus, button:active, button:hover {
        /* 20% Overlay 2, 80% mantle */
        background-color: rgb(48, 50, 66);
        outline-style: none;
    }

    #lock {
        background-image: url("${../home/wlogout/icons/lock.svg}");
    }

    #logout {
        background-image: url("${../home/wlogout/icons/logout.svg}");
    }

    #suspend {
        background-image: url("${../home/wlogout/icons/suspend.svg}");
    }

    #hibernate {
        background-image: url("${../home/wlogout/icons/hibernate.svg}");
    }

    #shutdown {
        background-image: url("${../home/wlogout/icons/shutdown.svg}");
    }

    #reboot {
        background-image: url("${../home/wlogout/icons/reboot.svg}");
    }
  '';
}

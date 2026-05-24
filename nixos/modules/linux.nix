{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
    inputs.vicinae.homeManagerModules.default
  ];

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

  services.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/terminal" = [ "kitty.desktop" ];
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      #####################
      ### LOOK AND FEEL ###
      #####################

      # Refer to https://wiki.hypr.land/Configuring/Variables/

      # https://wiki.hypr.land/Configuring/Variables/#animations
      animations = {
        enabled = "yes";

        # Default curves, see https://wiki.hypr.land/Configuring/Animations/#curves
        bezier = [
          #NAME,           X0,   Y0,   X1,   Y1
          "easeOutQuint,   0.23, 1,    0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear,         0,    0,    1,    1"
          "almostLinear,   0.5,  0.5,  0.75, 1"
          "quick,          0.15, 0,    0.1,  1"
        ];

        # Default animations, see https://wiki.hypr.land/Configuring/Animations/
        animation = [
          #NAME,          ONOFF, SPEED, CURVE,        [STYLE]
          "global,        1,     10,    default"
          "border,        1,     5.39,  easeOutQuint"
          "windows,       1,     4.79,  easeOutQuint"
          "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
          "windowsOut,    1,     1.49,  linear,       popin 87%"
          "fadeIn,        1,     1.73,  almostLinear"
          "fadeOut,       1,     1.46,  almostLinear"
          "fade,          1,     3.03,  quick"
          "layers,        1,     3.81,  easeOutQuint"
          "layersIn,      1,     4,     easeOutQuint, fade"
          "layersOut,     1,     1.5,   linear,       fade"
          "fadeLayersIn,  1,     1.79,  almostLinear"
          "fadeLayersOut, 1,     1.39,  almostLinear"
          "workspaces,    1,     1.94,  almostLinear, fade"
          "workspacesIn,  1,     1.21,  almostLinear, fade"
          "workspacesOut, 1,     1.94,  almostLinear, fade"
          "zoomFactor,    1,     7,     quick"
        ];
      };

      #############
      ### INPUT ###
      #############

      # https://wiki.hypr.land/Configuring/Variables/#input
      input = {
        kb_layout = "gb";
        kb_options = "ctrl:nocaps";
      };

      device = {
        name = "topre-corporation-hhkb-professional";
        kb_layout = "us";
      };

      ###################
      ### MY PROGRAMS ###
      ###################

      # See https://wiki.hypr.land/Configuring/Keywords/

      # Set programs that you use
      "$terminal" = "kitty";

      ###################
      ### KEYBINDINGS ###
      ###################

      # See https://wiki.hypr.land/Configuring/Keywords/
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, Space, exec, vicinae toggle"
        "$mainMod CTRL, Q, exec, ${lib.getExe pkgs.hyprlock}"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
      ];

      bindl = [
        # Lock on lid close
        ", switch:on:Lid Switch, exec, hyprlock"
      ];

      layerrule = [
        # blur
        {
          name = "vicinae-blur";
          blur = "on";
          ignore_alpha = 0;
          "match:namespace" = "vicinae";
        }

        # disable animation for vicinae only
        {
          name = "vicinae-no-animation";
          no_anim = "on";
          "match:namespace" = "vicinae";
        }
      ];
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
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/lock.svg");
    }

    #logout {
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/logout.svg");
    }

    #suspend {
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/suspend.svg");
    }

    #hibernate {
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/hibernate.svg");
    }

    #shutdown {
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/shutdown.svg");
    }

    #reboot {
        background-image: url("${inputs.catppuccin-wlogout}/icons/wleave/mocha/blue/reboot.svg");
    }
  '';
}

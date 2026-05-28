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

  gtk.gtk4.theme = null;

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

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        "layer" = "bottom";
        "position" = "top";
        "height" = 45;
        "spacing" = 2;
        "exclusive" = true;
        "gtk-layer-shell" = true;
        "passthrough" = false;
        "fixed-center" = true;
        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        "modules-center" = [ ];
        "modules-right" = [
          "cpu"
          "memory"
          "pulseaudio"
          "network"
          "clock#simpleclock"
          "battery"
          "tray"
          "custom/power"
        ];
        "hyprland/workspaces" = {
          "on-click" = "activate";
          "format" = "{id}";
          "all-outputs" = true;
          "disable-scroll" = false;
          "active-only" = false;
        };
        "hyprland/window" = {
          "format" = "{title}";
        };
        "tray" = {
          "show-passive-items" = true;
          "spacing" = 10;
        };
        "clock#simpleclock" = {
          "format" = " {:%H:%M}";
          "calendar" = {
            "format" = {
              "days" = "<span weight='normal'>{}</span>";
              "months" = "<span color='#cdd6f4'><b>{}</b></span>";
              "today" = "<span color='#f38ba8' weight='700'><u>{}</u></span>";
              "weekdays" = "<span color='#f9e2af'><b>{}</b></span>";
              "weeks" = "<span color='#a6e3a1'><b>W{}</b></span>";
            };
            "mode" = "month";
            "mode-mon-col" = 1;
            "on-scroll" = 1;
          };
          "tooltip-format" = "<span color='#cdd6f4'><tt><small>{calendar}</small></tt></span>";
        };
        "clock" = {
          "format" = " {=L%a %d %b}";
          "calendar" = {
            "format" = {
              "days" = "<span weight='normal'>{}</span>";
              "months" = "<span color='#cdd6f4'><b>{}</b></span>";
              "today" = "<span color='#f38ba8' weight='700'><u>{}</u></span>";
              "weekdays" = "<span color='#f9e2af'><b>{}</b></span>";
              "weeks" = "<span color='#a6e3a1'><b>W{}</b></span>";
            };
            "mode" = "month";
            "mode-mon-col" = 1;
            "on-scroll" = 1;
          };
          "tooltip-format" = "<span color='#cdd6f4'><tt><small>{calendar}</small></tt></span>";
        };
        "cpu" = {
          "format" = " {usage}%";
          "interval" = 2;
        };
        "memory" = {
          "format" = " {used:.1f}Gi";
          "tooltip-format" = "Used= {used:.1f}G/{total:.1f}G\nSwap= {swapUsed:.1f}G/{swapTotal:.1f}G";
        };
        "pulseaudio" = {
          "format" = "{icon}";
          "format-muted" = " ";
          "format-icons" = {
            "headphone" = "";
            "default" = [
              " "
              " "
            ];
          };
          "on-click" = "pavucontrol";
          "tooltip-format" = "{desc}\nVolume= {volume}%";
        };
        "network" = {
          "format-ethernet" = "󰈀";
          "format-icons" = [
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          "format-wifi" = "{icon}";
          "format-disconnected" = "󰤭";
          "on-click" = "${lib.getExe pkgs.kitty} ${lib.getExe pkgs.impala}";
          "tooltip-format" = "{ifname}\nIP= {ipaddr}\nGateway= {gwaddr}";
          "tooltip-format-wifi" = "{essid} ({signalStrength}%)\nIP= {ipaddr}\nGateway= {gwaddr}";
          "tooltip-format-disconnected" = "Disconnected";
        };
        "battery" = {
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{capacity}% <span>{icon}</span>";
          "format-charging" = "{capacity}% <span>󰂄</span>";
          "format-plugged" = "󰚥";
          "format-icons" = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };
        "custom/sep" = {
          "format" = "|";
          "tooltip" = false;
        };
        "custom/power" = {
          "tooltip" = false;
          "on-click" = "${lib.getExe pkgs.wlogout}";
          "format" = "⏻";
        };
      };
    };
    style = ''
      @import "${inputs.catppuccin-waybar}/themes/mocha.css";

      /* Global */
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 16px;
        border: none;
        border-radius: 0;
        min-height: 0;
        min-width: 0;
      }

      /* Bar background */
      window#waybar {
        transition-property: background-color;
        transition-duration: 0.5s;
        background-color: @crust;
      }

      /* Workspaces */
      #workspaces button {
        padding: 0.3rem 0.6rem;
        margin: 0.4rem 0.25rem;
        border-radius: 6px;
        background-color: @base;
        color: @text;
      }

      #workspaces button:hover {
        color: @base;
        background-color: @text;
      }

      #workspaces button.active {
        background-color: @base;
        color: @blue;
      }

      #workspaces button.urgent {
        background-color: @base;
        color: @red;
      }

      /* All modules via container trick */
      #clock,
      #pulseaudio,
      #network,
      #battery,
      #custom-logo,
      #custom-power,
      #custom-spotify,
      #custom-notification,
      #cpu,
      #tray,
      #memory,
      #window {
        padding: 0.3rem 0.6rem;
        margin: 0.4rem 0.25rem;
        border-radius: 6px;
        background-color: @base;
      }

      /* Separator */
      #custom-sep {
        padding: 0;
        color: @surface0;
      }

      /* Hide empty window module */
      window#waybar.empty #window {
        background-color: transparent;
      }

      /* Module colours */
      #cpu {
        color: @teal;
      }

      #memory {
        color: @mauve;
      }

      #clock {
        color: @sapphire;
      }

      #clock.simpleclock {
        color: @blue;
      }

      #window {
        color: @text;
      }

      #pulseaudio {
        color: @lavender;
      }

      #pulseaudio.muted {
        color: @subtext0;
      }

      #custom-logo {
        color: @blue;
      }

      #custom-power {
        color: @red;
      }

      /* Tooltip */
      tooltip {
        background-color: @mantle;
        border: 2px solid @blue;
        color: @text;
      }
    '';
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = {
        blur_passes = 1;
      };
      label = [
        # TIME
        {
          text = "$TIME";
          color = "$text";
          font_size = 90;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }

        # DATE
        {
          text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
      input-field = {
        size = "300, 60";
        outline_thickness = 4;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        fade_on_empty = false;
        placeholder_text = "<span><i>󰌾 Logged in as </i><span>$USER</span></span>";
        hide_input = false;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -47";
        halign = "center";
        valign = "center";
      };
    };
  };

  programs.wlogout = {
    enable = true;
    style = ''
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
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
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

}

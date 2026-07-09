{
  flake.homeModules.waybar =
    {
      pkgs,
      inputs,
      lib,
      osConfig,
      ...
    }:
    {
      stylix.targets.waybar.colors.enable = false;

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
              "idle_inhibitor"
              "hyprland/submap"
              "group/cpu-display"
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
              "disable-scroll" = false;

              "all-outputs" = false;
              "active-only" = false;
            };
            "hyprland/window" = {
              "format" = "{title}";
            };
            "hyprland/submap" = {
              "format" = "󰘳 {}";
              "max-length" = 20;
              "tooltip" = false;
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
            "group/cpu-display" = {
              "orientation" = "horizontal";
              "modules" = [
                "custom/cpu-icon"
                "cpu"
              ];
            };
            "custom/cpu-icon" = {
              "format" = " ";
              "tooltip" = false;
              "on-click" = "${lib.getExe osConfig.hostSettings.terminal} ${lib.getExe pkgs.btop}";
            };
            "cpu" = {
              "format" = "{usage}%";
              "interval" = 2;
              "min-length" = 3;
              "align" = 1;
              "on-click" = "${lib.getExe osConfig.hostSettings.terminal} ${lib.getExe pkgs.btop}";
            };
            "memory" = {
              "format" = " {used:.1f}Gi";
              "tooltip-format" = "Used= {used:.1f}G/{total:.1f}G\nSwap= {swapUsed:.1f}G/{swapTotal:.1f}G";
              "on-click" = "${lib.getExe osConfig.hostSettings.terminal} ${lib.getExe pkgs.btop}";
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
              "on-click" = "${lib.getExe pkgs.pavucontrol}";
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
              "on-click" = "${lib.getExe osConfig.hostSettings.terminal} ${lib.getExe pkgs.impala}";
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
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "󰅶 "; # Icon when caffeine mode is ON
                deactivated = "󰛊 "; # Icon when caffeine mode is OFF
              };
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

          #workspaces button.visible {
            background-color: @base;
            color: @blue;
          }

          #workspaces button.active {
            background-color: @base;
            color: @blue;
          }

          #workspaces button.urgent {
            background-color: @red;
            color: @base;
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
          #cpu-display,
          #tray,
          #memory,
          #window,
          #submap {
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
          #cpu-display {
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

          #submap {
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
    };
}

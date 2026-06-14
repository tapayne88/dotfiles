{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;

    configType = "lua";
    settings =
      let
        mkLuaInline = lib.generators.mkLuaInline;
        toLua = lib.generators.toLua;
        mkArgs = args: { _args = args; };
        bind =
          keys: dispatcher: options:
          mkArgs [
            keys
            dispatcher
            options
          ];
        curve = name: points: mkLuaInline "hl.curve(${name}, ${toLua { } points})";
        dsp = {
          exec_cmd = app: mkLuaInline "hl.dsp.exec_cmd('${app}')";
          focus = arg: mkLuaInline "hl.dsp.focus(${toLua { } arg})";
          window = {
            move = arg: mkLuaInline "hl.dsp.window.move(${toLua { } arg})";
            drag = mkLuaInline "hl.dsp.window.drag()";
            resize = mkLuaInline "hl.dsp.window.resize()";
            close = mkLuaInline "hl.dsp.window.close()";
            kill = mkLuaInline "hl.dsp.window.kill()";
          };
          workspace = {
            move = arg: mkLuaInline "hl.dsp.workspace.move(${toLua { } arg})";
          };
        };
        mod = "SUPER";
        workspaces = lib.stringToCharacters "abcdefgimnopqrstuvwxyz";
      in
      {
        config = {
          input = {
            kb_layout = "gb";
            kb_options = "ctrl:nocaps";
          };

          animations.enabled = true;
        };

        device = [
          {
            name = "topre-corporation-hhkb-professional";
            kb_layout = "us";
          }
        ];

        curve = [
          (mkArgs [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ])
          (mkArgs [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0.05
                ]
                [
                  0.36
                  1
                ]
              ];
            }
          ])
          (mkArgs [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ])
          (mkArgs [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1
                ]
              ];
            }
          ])
          (mkArgs [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ])
        ];

        animation = [
          {
            leaf = "global";
            enabled = true;
            speed = 10;
            bezier = "default";
          }
          {
            leaf = "border";
            enabled = true;
            speed = 5.39;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windows";
            enabled = true;
            speed = 4.79;
            bezier = "easeOutQuint";
          }
          {
            leaf = "windowsIn";
            enabled = true;
            speed = 4.1;
            bezier = "easeOutQuint";
            style = "popin 87%";
          }
          {
            leaf = "windowsOut";
            enabled = true;
            speed = 1.49;
            bezier = "linear";
            style = "popin 87%";
          }
          {
            leaf = "fadeIn";
            enabled = true;
            speed = 1.73;
            bezier = "almostLinear";
          }
          {
            leaf = "fadeOut";
            enabled = true;
            speed = 1.46;
            bezier = "almostLinear";
          }
          {
            leaf = "fade";
            enabled = true;
            speed = 3.03;
            bezier = "quick";
          }
          {
            leaf = "layers";
            enabled = true;
            speed = 3.81;
            bezier = "easeOutQuint";
          }
          {
            leaf = "layersIn";
            enabled = true;
            speed = 4;
            bezier = "easeOutQuint";
            style = "fade";
          }
          {
            leaf = "layersOut";
            enabled = true;
            speed = 1.5;
            bezier = "linear";
            style = "fade";
          }
          {
            leaf = "fadeLayersIn";
            enabled = true;
            speed = 1.79;
            bezier = "almostLinear";
          }
          {
            leaf = "fadeLayersOut";
            enabled = true;
            speed = 1.39;
            bezier = "almostLinear";
          }
          {
            leaf = "workspaces";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesIn";
            enabled = true;
            speed = 1.21;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "workspacesOut";
            enabled = true;
            speed = 1.94;
            bezier = "almostLinear";
            style = "fade";
          }
          {
            leaf = "zoomFactor";
            enabled = true;
            speed = 7;
            bezier = "quick";
          }
        ];

        layer_rule = [
          # blur
          {
            match.namespace = "vicinae";
            blur = true;
            ignore_alpha = 0;
          }

          # disable animation for vicinae only
          {
            match.namespace = "vicinae";
            no_anim = true;
          }
        ];

        bind = lib.flatten [
          (bind "${mod} + Space" (dsp.exec_cmd "vicinae toggle") { })
          (bind "${mod} + CTRL + Q" (dsp.exec_cmd "${lib.getExe pkgs.hyprlock}") { })

          # Super + Ctrl + 4 screenshots
          (bind "${mod} + CTRL + 4"
            (dsp.exec_cmd "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${lib.getExe pkgs.satty} --filename -")
            { }
          )

          (bind "${mod} + h" (dsp.focus { direction = "l"; }) { })
          (bind "${mod} + j" (dsp.focus { direction = "d"; }) { })
          (bind "${mod} + k" (dsp.focus { direction = "u"; }) { })
          (bind "${mod} + l" (dsp.focus { direction = "r"; }) { })

          (bind "${mod} + SHIFT + h" (dsp.window.move { direction = "l"; }) { })
          (bind "${mod} + SHIFT + j" (dsp.window.move { direction = "d"; }) { })
          (bind "${mod} + SHIFT + k" (dsp.window.move { direction = "u"; }) { })
          (bind "${mod} + SHIFT + l" (dsp.window.move { direction = "r"; }) { })

          # Switch workspaces with mainMod + [0-9]
          (bind "${mod} + 1" (dsp.focus { workspace = "1"; }) { })
          (bind "${mod} + 2" (dsp.focus { workspace = "2"; }) { })
          (bind "${mod} + 3" (dsp.focus { workspace = "3"; }) { })
          (bind "${mod} + 4" (dsp.focus { workspace = "4"; }) { })
          (bind "${mod} + 5" (dsp.focus { workspace = "5"; }) { })
          (bind "${mod} + 5" (dsp.focus { workspace = "6"; }) { })
          (bind "${mod} + 7" (dsp.focus { workspace = "7"; }) { })
          (bind "${mod} + 8" (dsp.focus { workspace = "8"; }) { })
          (bind "${mod} + 9" (dsp.focus { workspace = "9"; }) { })
          (bind "${mod} + 0" (dsp.focus { workspace = "0"; }) { })

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          (bind "${mod} + SHIFT + 1" (dsp.window.move { workspace = "1"; }) { })
          (bind "${mod} + SHIFT + 2" (dsp.window.move { workspace = "2"; }) { })
          (bind "${mod} + SHIFT + 3" (dsp.window.move { workspace = "3"; }) { })
          (bind "${mod} + SHIFT + 4" (dsp.window.move { workspace = "4"; }) { })
          (bind "${mod} + SHIFT + 5" (dsp.window.move { workspace = "5"; }) { })
          (bind "${mod} + SHIFT + 6" (dsp.window.move { workspace = "6"; }) { })
          (bind "${mod} + SHIFT + 7" (dsp.window.move { workspace = "7"; }) { })
          (bind "${mod} + SHIFT + 8" (dsp.window.move { workspace = "8"; }) { })
          (bind "${mod} + SHIFT + 9" (dsp.window.move { workspace = "9"; }) { })
          (bind "${mod} + SHIFT + 0" (dsp.window.move { workspace = "0"; }) { })

          # Mouse bindings
          (bind "${mod} + mouse:272" (dsp.window.drag) { mouse = true; })
          (bind "${mod} + mouse:273" (dsp.window.resize) { mouse = true; })

          # Lock on lid close
          (bind "switch:on:Lid Switch" (dsp.exec_cmd "${lib.getExe pkgs.hyprlock}") { })
        ];
      };

    extraConfig =
      let
        resizeValue = "30";
      in
      ''
        hl.bind("ALT + R", hl.dsp.submap("resize"))

        -- Start a submap called "resize".
        hl.define_submap("resize", function()

            -- Set repeating binds for resizing the active window.
            hl.bind("l", hl.dsp.window.resize({ x = ${resizeValue}, y = 0, relative = true}), { repeating = true })
            hl.bind("h", hl.dsp.window.resize({ x = -${resizeValue}, y = 0, relative = true}), { repeating = true })
            hl.bind("k", hl.dsp.window.resize({ x = 0, y = ${resizeValue}, relative = true}), { repeating = true })
            hl.bind("j", hl.dsp.window.resize({ x = 0, y = -${resizeValue}, relative = true}), { repeating = true })

            -- Use `reset` to go back to the global submap
            hl.bind("escape", hl.dsp.submap("reset"))
        end)
      '';
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
          "idle_inhibitor"
          "hyprland/submap"
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

  services.mako.enable = true;
}

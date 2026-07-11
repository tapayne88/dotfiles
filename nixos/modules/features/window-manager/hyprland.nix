{
  flake.homeModules.hyprland =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      internalMonitor = osConfig.hostSettings.internalMonitor;
      mod = "SUPER";
    in
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
            dsp = {
              exec_cmd = app: mkLuaInline "hl.dsp.exec_cmd('${app}')";
              focus = arg: mkLuaInline "hl.dsp.focus(${toLua { } arg})";
              group = {
                toggle = mkLuaInline "hl.dsp.group.toggle()";
              };
              window = {
                move = arg: mkLuaInline "hl.dsp.window.move(${toLua { } arg})";
                drag = mkLuaInline "hl.dsp.window.drag()";
                resize = mkLuaInline "hl.dsp.window.resize()";
                close = mkLuaInline "hl.dsp.window.close()";
                kill = mkLuaInline "hl.dsp.window.kill()";
                cycle_next = arg: mkLuaInline "hl.dsp.window.cycle_next(${toLua { } arg})";
                float = arg: mkLuaInline "hl.dsp.window.float(${toLua { } arg})";
                fullscreen = arg: mkLuaInline "hl.dsp.window.fullscreen(${toLua { } arg})";
              };
              workspace = {
                move = arg: mkLuaInline "hl.dsp.workspace.move(${toLua { } arg})";
              };
            };
          in
          {
            config = {
              general = {
                gaps_in = 5;
                gaps_out = 10;
              };

              decoration = {
                rounding = 20;
                rounding_power = 2;

                shadow = {
                  enabled = true;
                  range = 4;
                  render_power = 3;
                };

                blur = {
                  enabled = true;
                  size = 3;
                  passes = 2;
                  vibrancy = 0.1696;
                };
              };

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

            monitor = [
              # Built-in
              {
                output = "${internalMonitor}";
                mode = "preferred";
                position = "auto";
                scale = 1;
              }
              # Home external monitor
              {
                output = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                mode = "preferred";
                position = "auto";
                scale = 1;
              }
              # Fallback
              {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = 1;
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
              {
                name = "noctalia";
                match = {
                  namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$";
                };
                no_anim = true;
                ignore_alpha = 0.5;
                blur = true;
                blur_popups = true;
              }
            ];

            window_rule = [
              # Noctalia Settings
              {
                match = {
                  class = "dev.noctalia.Noctalia";
                };
                float = true;
                size = [
                  1080
                  920
                ];
              }
            ];

            workspace_rule = [
              # External Monitor (Workspaces 1-5)
              {
                workspace = "1";
                monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                default = true;
                persistent = true;
              }
              {
                workspace = "2";
                monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                persistent = true;
              }
              {
                workspace = "3";
                monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                persistent = true;
              }
              {
                workspace = "4";
                monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                persistent = true;
              }
              {
                workspace = "5";
                monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
                persistent = true;
              }

              # Built-in Monitor (Workspaces 6-10)
              {
                workspace = "6";
                monitor = "${internalMonitor}";
                default = true;
                persistent = true;
              }
              {
                workspace = "7";
                monitor = "${internalMonitor}";
              }
              {
                workspace = "8";
                monitor = "${internalMonitor}";
              }
              {
                workspace = "9";
                monitor = "${internalMonitor}";
              }
              {
                workspace = "10";
                monitor = "${internalMonitor}";
              }
            ];

            bind =
              let
                ipc = "noctalia msg";
              in
              lib.flatten [
                (bind "${mod} + Space" (dsp.exec_cmd "${ipc} panel-toggle launcher") { })
                (bind "${mod} + CTRL + Q" (dsp.exec_cmd "${ipc} session lock") { })

                (bind "${mod} + Tab" (dsp.focus { last = true; }) { })

                (bind "${mod} + G" (dsp.group.toggle) { })
                (bind "${mod} + F" (dsp.window.float { action = "toggle"; }) { })
                (bind "${mod} + x" (dsp.window.fullscreen {
                  mode = "maximized";
                  action = "toggle";
                }) { })

                # Super + Ctrl + 4 screenshots
                (bind "${mod} + CTRL + 4"
                  (dsp.exec_cmd "${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${lib.getExe pkgs.satty} --filename -")
                  { }
                )

                # Media keys
                (bind "XF86AudioRaiseVolume" (dsp.exec_cmd "${ipc} volume-up") { })
                (bind "XF86AudioLowerVolume" (dsp.exec_cmd "${ipc} volume-down") { })
                (bind "XF86AudioMute" (dsp.exec_cmd "${ipc} volume-mute") { })
                (bind "XF86MonBrightnessUp" (dsp.exec_cmd "${ipc} brightness-up") { })
                (bind "XF86MonBrightnessDown" (dsp.exec_cmd "${ipc} brightness-down") { })

                # Switch workspaces with mainMod + [0-9]
                (bind "${mod} + 1" (dsp.focus { workspace = "1"; }) { })
                (bind "${mod} + 2" (dsp.focus { workspace = "2"; }) { })
                (bind "${mod} + 3" (dsp.focus { workspace = "3"; }) { })
                (bind "${mod} + 4" (dsp.focus { workspace = "4"; }) { })
                (bind "${mod} + 5" (dsp.focus { workspace = "5"; }) { })
                (bind "${mod} + 6" (dsp.focus { workspace = "6"; }) { })
                (bind "${mod} + 7" (dsp.focus { workspace = "7"; }) { })
                (bind "${mod} + 8" (dsp.focus { workspace = "8"; }) { })
                (bind "${mod} + 9" (dsp.focus { workspace = "9"; }) { })
                (bind "${mod} + 0" (dsp.focus { workspace = "10"; }) { })

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
                (bind "${mod} + SHIFT + 0" (dsp.window.move { workspace = "10"; }) { })

                # Mouse bindings
                (bind "${mod} + mouse:272" (dsp.window.drag) { mouse = true; })
                (bind "${mod} + mouse:273" (dsp.window.resize) { mouse = true; })

                # Lock on lid close
                (bind "switch:on:Lid Switch" (dsp.exec_cmd "${ipc} session lock") { })
              ];

            on = mkArgs [
              "hyprland.start"
              (mkLuaInline ''
                function()
                  hl.exec_cmd("uwsm app -- noctalia") 
                  hl.exec_cmd("uwsm app -- ${lib.getExe pkgs.syncthingtray} --wait") 
                  hl.exec_cmd("uwsm app -- ${lib.getExe pkgs.tailscale} systray") 
                end'')
            ];
          };

        extraConfig = builtins.readFile ./submaps.lua;
      };
    };
}

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

        workspace_rule = [
          # External Monitor (Workspaces 1-5)
          {
            workspace = "1";
            monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
            default = true;
          }
          {
            workspace = "2";
            monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
          }
          {
            workspace = "3";
            monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
          }
          {
            workspace = "4";
            monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
          }
          {
            workspace = "5";
            monitor = "desc: LG Electronics LG HDR 4K 107NTYT9P250";
          }

          # Built-in Monitor (Workspaces 6-10)
          {
            workspace = "6";
            monitor = "${internalMonitor}";
            default = true;
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

        bind = lib.flatten [
          (bind "${mod} + Space" (dsp.exec_cmd "vicinae toggle") { })
          (bind "${mod} + CTRL + Q" (dsp.exec_cmd "${lib.getExe pkgs.hyprlock}") { })

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
          (bind "switch:on:Lid Switch" (dsp.exec_cmd "${lib.getExe pkgs.hyprlock}") { })
        ];

        on = mkArgs [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("uwsm app -- syncthingtray --wait") 
              hl.exec_cmd("uwsm app -- tailscale systray") 
            end'')
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
            hl.bind("Escape", hl.dsp.submap("reset"))
            hl.bind("Return", hl.dsp.submap("reset"))
        end)
      ''
      + ''
        -- A completely native function leveraging the internal window.group state
        local function get_group_position()
            local win = hl.get_active_window()
            if not win or not win.group then
                return nil, nil
            end

            local group = win.group
            -- If the group only has 1 window, treat it as a normal tiled layout
            if group.size <= 1 then
                return nil, nil
            end

            -- Match our current window's hardware address against the group's members array
            for index, group_win in ipairs(group.members) do
                if win.address == group_win.address then
                    return index, group.size
                end
            end

            return nil, nil
        end

        --- ==========================================
        --- SMART WINDOW SWITCHING (Super + h/j/k/l)
        --- ==========================================

        -- Focus Left: Cycle tab backward, or break out left if at the first tab
        hl.bind("${mod} + h", function()
            local idx, total = get_group_position()
            if idx and idx > 1 then
                hl.dispatch(hl.dsp.group.prev())
            else
                hl.dispatch(hl.dsp.focus({ direction = "left" }))
            end
        end)

        -- Focus Right: Cycle tab forward, or break out right if at the last tab
        hl.bind("${mod} + l", function()
            local idx, total = get_group_position()
            if idx and idx < total then
                hl.dispatch(hl.dsp.group.next())
            else
                hl.dispatch(hl.dsp.focus({ direction = "right" }))
            end
        end)

        -- Vertical focus shifts always step outside the horizontal tab layout
        hl.bind("${mod} + k", hl.dsp.focus({ direction = "up" }))
        hl.bind("${mod} + j", hl.dsp.focus({ direction = "down" }))


        --- ==========================================
        --- SMART WINDOW MOVING (Super + Shift + h/j/k/l)
        --- ==========================================

        -- Move Left: Shift tab position backward, or eject window left at the edge
        hl.bind("${mod} + SHIFT + h", function()
            local idx, total = get_group_position()
            if idx and idx > 1 then
                hl.dispatch(hl.dsp.group.move_window({ forward = false }))
            else
                hl.dispatch(hl.dsp.window.move({ direction = "left", group_aware = true }))
            end
        end)

        -- Move Right: Shift tab position forward, or eject window right at the edge
        hl.bind("${mod} + SHIFT + l", function()
            local idx, total = get_group_position()
            if idx and idx < total then
                hl.dispatch(hl.dsp.group.move_window({ forward = true }))
            else
                hl.dispatch(hl.dsp.window.move({ direction = "right", group_aware = true }))
            end
        end)

        -- Vertical shifts gracefully slice windows out of the tab bar up or down
        hl.bind("${mod} + SHIFT + k", hl.dsp.window.move({ direction = "up", group_aware = true }))
        hl.bind("${mod} + SHIFT + j", hl.dsp.window.move({ direction = "down", group_aware = true }))
      ''
      + ''
        --- ==========================================
        --- WINDOW MOVE SUBMAP (Super + w)
        --- ==========================================

        -- 1. Trigger the submap entry point
        hl.bind("${mod} + w", hl.dsp.submap("window_move"))

        -- 2. Define the isolated keybind envelope for the submap
        hl.define_submap("window_move", function()

            -- Bare keys (h,j,k,l) execute classic layout shuffles ignoring group tabs
            hl.bind("${mod} + h", hl.dsp.focus({ direction = "left" }))
            hl.bind("${mod} + l", hl.dsp.focus({ direction = "right" }))
            hl.bind("${mod} + k", hl.dsp.focus({ direction = "up" }))
            hl.bind("${mod} + j", hl.dsp.focus({ direction = "down" }))

            -- Catch Shift + directional keys too just in case muscle memory kicks in
            hl.bind("${mod} + SHIFT + h", hl.dsp.window.move({ direction = "left", group_aware = false }))
            hl.bind("${mod} + SHIFT + l", hl.dsp.window.move({ direction = "right", group_aware = false }))
            hl.bind("${mod} + SHIFT + k", hl.dsp.window.move({ direction = "up", group_aware = false }))
            hl.bind("${mod} + SHIFT + j", hl.dsp.window.move({ direction = "down", group_aware = false }))

            -- 3. Exit vectors to return back to normal global operation
            hl.bind("Escape", hl.dsp.submap("reset"))
            hl.bind("Return", hl.dsp.submap("reset"))
        end)
      '';
  };
}

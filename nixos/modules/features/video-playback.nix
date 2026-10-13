{
  flake.homeModules.video-playback = {
    programs.mpv = {
      enable = true;
      config = {
        # Prefer Wayland natively
        gpu-context = "wayland";

        # High-quality video output and hardware decoding
        vo = "gpu";
        profile = "gpu-hq";
        hwdec = "auto-safe";

        # Keep the window borderless for a cleaner Hyprland look
        border = "no";

        # Don't close the player after the video ends
        keep-open = true;

        # Save playback position on quit
        save-position-on-quit = true;
      };

      # Custom keybindings
      bindings = {
        WHEEL_UP = "seek 10";
        WHEEL_DOWN = "seek -10";
        "UP" = "add volume 5";
        "DOWN" = "add volume -5";
      };
    };
  };
}

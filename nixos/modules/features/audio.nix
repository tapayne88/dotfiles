{
  flake.nixosModules.audio = { pkgs, ... }: {
    # Grants PipeWire real-time CPU scheduling to prevent audio stuttering
    security.rtkit.enable = true;

    services.pipewire = {
      # Starts the core PipeWire media server
      enable = true;

      # Intercepts audio from older programs designed for ALSA
      alsa.enable = true;
      # Needed for 32-bit applications (often older games or Wine prefixes)
      alsa.support32Bit = true;

      # Emulates a PulseAudio server for modern desktop applications
      pulse.enable = true;

      # Manages device routing, fallbacks, and hotplug logic
      wireplumber.enable = true;
    };

    environment.systemPackages = [
      pkgs.pavucontrol # audio control gui
    ];

    # Add friendly description to USB-C audio device on Framework Laptop 13 Pro
    services.pipewire.wireplumber.extraConfig."51-rename-monitor" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.pci-0000_00_1f.3.pro-output-3";
            }
          ];
          actions = {
            "update-props" = {
              "node.description" = "USB-C Display Audio";
            };
          };
        }
      ];
    };
  };
}

{
  flake.nixosModules.gaming =
    { pkgs, ... }:

    {
      allowedUnfreePackages = [
        "steam"
        "steam-unwrapped"
      ];

      # Enable OpenGL/Vulkan for the Framework's integrated graphics
      hardware.graphics = {
        enable = true;
        enable32Bit = true; # Crucial for running 32-bit Windows games
      };

      # Enable Steam and Custom Proton
      programs.steam = {
        enable = true;

        # Open firewall ports for Steam features
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;

        # Declaratively install Proton-GE as a compatibility tool
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
      };

      # Enable udev rules for Steam hardware like controllers
      hardware.steam-hardware.enable = true;
    };
}

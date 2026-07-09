{
  flake.nixosModules.audio = { pkgs, ... }: {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    environment.systemPackages = [
      pkgs.pavucontrol # audio control gui
    ];
  };
}

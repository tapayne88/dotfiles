{
  flake.nixosModules.vpn = { pkgs, config, ... }: {
    services.tailscale.enable = true;

    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/tailscale"
    ];

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}

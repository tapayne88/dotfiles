{
  flake.nixosModules.vpn = { pkgs, config, ... }: {
    services.tailscale.enable = true;

    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/tailscale"
    ];

    environment.systemPackages = with pkgs; [
      tailscale
    ];

    # Prevent NetworkManager from hanging on Tailscale interfaces
    networking.networkmanager.unmanaged = [ "interface-name:tailscale*" ];
  };
}

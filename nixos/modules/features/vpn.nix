{
  flake.nixosModules.vpn = { pkgs, ... }: {
    services.tailscale.enable = true;

    environment.persistence."/persist".directories = [
      "/var/lib/tailscale"
    ];

    environment.systemPackages = with pkgs; [
      tailscale
    ];
  };
}

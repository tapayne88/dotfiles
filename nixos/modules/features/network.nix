{
  flake.nixosModules.network = { pkgs, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    environment.systemPackages = [
      pkgs.impala # wifi utility
    ];

    environment.persistence."/persist".directories = [
      "/var/lib/iwd"
    ];
  };
}

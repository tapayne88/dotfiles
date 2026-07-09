{
  flake.nixosModules.network = { pkgs, config, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    environment.systemPackages = [
      pkgs.impala # wifi utility
    ];

    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/iwd"
    ];
  };
}

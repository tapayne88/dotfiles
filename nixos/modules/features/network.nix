{
  flake.nixosModules.network = { pkgs, config, ... }: {
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # Ensure iwd finishes launching before NetworkManager starts listening
    systemd.services.NetworkManager = {
      wants = [ "iwd.service" ];
      after = [ "iwd.service" ];
    };

    hardware.bluetooth.enable = true;

    environment.systemPackages = [
      pkgs.impala # wifi utility
    ];

    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/iwd"
    ];
  };
}

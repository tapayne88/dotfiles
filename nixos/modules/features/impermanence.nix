{
  flake.nixosModules.impermanence =
    { config, ... }:
    let
      username = config.hostSettings.username;
    in
    {
      environment.persistence."${config.hostSettings.persistenceMountPath}" = {
        hideMounts = true;
        directories = [
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/etc/nixos"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_rsa_key"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /persist/home/${username} 0700 ${username} users -"
      ];
    };
}

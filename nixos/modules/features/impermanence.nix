{
  flake.nixosModules.impermanence = {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/iwd"
        "/var/lib/nixos"
        "/var/lib/tailscale"
        "/home"
        "/etc/nixos"

        {
          directory = "/var/lib/cups";
          user = "root";
          group = "lp";
          mode = "0755";
        }
        {
          directory = "/var/cache/tuigreet";
          user = "greeter";
          group = "greeter";
          mode = "0755";
        }
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
  };
}

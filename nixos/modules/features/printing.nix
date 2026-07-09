{
  flake.nixosModules.printing = { config, ... }: {
    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable Avahi for network printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      {
        directory = "/var/lib/cups";
        user = "root";
        group = "lp";
        mode = "0755";
      }
    ];
  };
}

{
  flake.nixosModules.printing = { config, pkgs, ... }: {

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

    # Canon TS8150 Setup
    allowedUnfreePackages = [ "cnijfilter2" ];
    services.printing.drivers = [ pkgs.cnijfilter2 ];
    hardware.printers = {
      ensurePrinters = [
        {
          name = "Canon_TS8150";
          location = "Home Office";
          description = "Canon PIXMA TS8150";
          deviceUri = "ipp://192.168.1.51:631/ipp/print";
          model = "canonts8100.ppd";
          ppdOptions = {
            PageSize = "A4";
          };
        }
      ];
      ensureDefaultPrinter = "Canon_TS8150";
    };
  };
}

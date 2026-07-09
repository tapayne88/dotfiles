{
  flake.nixosModules.printing = {
    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable Avahi for network printer discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}

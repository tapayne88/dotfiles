{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hostSettings = {
    username = "tpayne";
    internalMonitor = "LVDS-1";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkpad";

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # This handles the login screen (if using X11-based DM) and TTY
  services.xserver.xkb = {
    layout = "gb";
    options = "ctrl:nocaps";
  };

  # Force the TTY console to use the same layout as above
  console.useXkbConfig = true;

  services.gnome.gnome-keyring.enable = true;

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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}

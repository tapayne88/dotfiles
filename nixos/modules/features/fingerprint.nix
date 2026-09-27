{
  flake.nixosModules.fingerprint = { config, ... }: {
    # Enable fprintd for the Framework reader
    services.fprintd.enable = true;

    # Allow fingerprint auth for sudo
    security.pam.services.sudo.fprintAuth = true;

    # Explicitly tell logind to ignore the power button, use window manager to
    # bind to power off and lock screen
    services.logind.settings.Login.HandlePowerKey = "ignore";

    # Preserve registered fingerprints
    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/fprint"
    ];
  };
}

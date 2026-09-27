{
  flake.nixosModules.fingerprint = { config, ... }: {
    # Enable the fprintd daemon
    services.fprintd.enable = true;

    # Kill fingerprint auth at the root 'login' level so tuigreet stops inheriting it
    security.pam.services.login.fprintAuth = false;

    # Ensure greetd passes your typed password to unlock the GNOME keyring
    security.pam.services.greetd.enableGnomeKeyring = true;

    # Keep fingerprint auth working for sudo
    security.pam.services.sudo.fprintAuth = true;

    # Bring back the isolated PAM service for Noctalia
    security.pam.services.noctalia-lock.fprintAuth = true;

    # Point Noctalia to the isolated PAM service
    environment.sessionVariables = {
      NOCTALIA_PAM_SERVICE = "noctalia-lock";
    };

    # Explicitly tell logind to ignore the power button, use window manager to
    # bind to power off and lock screen
    services.logind.settings.Login.HandlePowerKey = "ignore";

    # Preserve registered fingerprints
    environment.persistence."${config.hostSettings.persistenceMountPath}".directories = [
      "/var/lib/fprint"
    ];
  };
}

{
  flake.homeModules.gpg =
    { pkgs, ... }:
    {
      programs.gpg = {
        enable = true;
        settings = {
          # Avoid leaking information
          no-emit-version = true;
          no-comments = true;

          # Display the long format of the ID of the keys and their fingerprint
          keyid-format = "0xlong";
          with-fingerprint = true;

          # Displays the validity of the keys
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
        };
      };

      # Runs as a launchd agent on macOS and a systemd user service on linux
      services.gpg-agent = {
        enable = true;
        pinentry.package =
          if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;
        defaultCacheTtl = 3600;
        maxCacheTtl = 86400;
        # Sets GPG_TTY so curses pinentry works as a fallback
        enableZshIntegration = true;
      };
    };
}

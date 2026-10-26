{
  flake.homeModules.gpg =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      passphraseRef = config.hostSettings.gpgPassphraseRef;

      platformPinentry =
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-qt;

      # Pinentry that answers passphrase requests with `op read`, so 1Password
      # approves every use instead of the passphrase being typed or cached.
      # Anything it can't answer (a retry after a wrong passphrase, choosing a
      # new passphrase, confirmations) replays the session into the platform
      # pinentry and proxies the rest of the conversation to it
      pinentry1password = pkgs.writeShellApplication {
        name = "pinentry-1password";
        text = ''
          # gpg-agent starts pinentry with a minimal environment. op comes from
          # the NixOS setgid wrapper on linux and the home-manager profile on macOS
          export PATH="/run/wrappers/bin:${config.home.profileDirectory}/bin:$PATH"

          args=("$@")
          buffer=()
          needs_human=0

          escape() {
            local s=''${1//%/%25}
            s=''${s//$'\r'/%0D}
            s=''${s//$'\n'/%0A}
            printf '%s' "$s"
          }

          forward() {
            printf '%s\n' "$1" >&"''${PIN[1]}"
            while IFS= read -r reply <&"''${PIN[0]}"; do
              printf '%s\n' "$reply"
              case $reply in OK* | ERR*) break ;; esac
            done
          }

          fallback() {
            coproc PIN { ${lib.getExe platformPinentry} "''${args[@]}"; }
            IFS= read -r _ <&"''${PIN[0]}"
            for cmd in "''${buffer[@]}"; do
              printf '%s\n' "$cmd" >&"''${PIN[1]}"
              while IFS= read -r reply <&"''${PIN[0]}"; do
                case $reply in OK* | ERR*) break ;; esac
              done
            done
            forward "$1"
            while IFS= read -r line; do
              forward "$line"
              case $line in BYE*) break ;; esac
            done
            exit 0
          }

          echo "OK Pleased to meet you"
          while IFS= read -r line; do
            case $line in
              GETPIN*)
                if [ "$needs_human" = 1 ]; then
                  fallback "$line"
                elif passphrase=$(op read --no-newline ${lib.escapeShellArg passphraseRef}) && [ -n "$passphrase" ]; then
                  printf 'D %s\nOK\n' "$(escape "$passphrase")"
                else
                  echo "ERR 83886179 Operation cancelled <Pinentry>"
                fi
                ;;
              CONFIRM* | MESSAGE*) fallback "$line" ;;
              SETERROR* | SETREPEAT*)
                needs_human=1
                buffer+=("$line")
                echo OK
                ;;
              GETINFO\ flavor) printf 'D 1password\nOK\n' ;;
              GETINFO\ pid) printf 'D %s\nOK\n' "$$" ;;
              RESET*)
                buffer=()
                needs_human=0
                echo OK
                ;;
              BYE*)
                echo "OK closing connection"
                exit 0
                ;;
              GETINFO*) echo OK ;;
              *)
                buffer+=("$line")
                echo OK
                ;;
            esac
          done
        '';
      };
    in
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
        pinentry.package = if passphraseRef != null then pinentry1password else platformPinentry;
        # With 1Password supplying the passphrase, skip the agent cache so every
        # use goes back through a 1Password approval
        defaultCacheTtl = if passphraseRef != null then 0 else 3600;
        maxCacheTtl = if passphraseRef != null then 0 else 86400;
        # Sets GPG_TTY so curses pinentry works as a fallback
        enableZshIntegration = true;
      };
    };
}

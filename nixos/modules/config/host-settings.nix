{
  flake.nixosModules.host-settings = { lib, pkgs, ... }: {
    options.hostSettings = {
      username = lib.mkOption { type = lib.types.str; };
      persistenceMountPath = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
      };
      dotfilesDir = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/git/dotfiles";
        description = ''
          Location of the dotfiles repository on this host. Used to derive
          NH_FLAKE for the nh CLI.

          The value is exported through a double-quoted shell export, so
          "$HOME" keeps it valid across platforms and users. Override per
          host wherever the repository is cloned somewhere else.
        '';
      };
      internalMonitor = lib.mkOption {
        description = "Configuration for the internal monitor.";
        type = lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = ''
                The display identifier (e.g., 'eDP-1' or 'DP-1').

                To easily find connected monitors directly from the hardware on a new machine, run:
                `grep -l "^connected$" /sys/class/drm/card*-*/status | awk -F'/' '{print $5}' | cut -d'-' -f2-`
              '';
            };
            scale = lib.mkOption {
              type = lib.types.int;
              default = 1;
              description = "Scaling factor for the internal monitor. For higher resolution displays 2 often makes more sense.";
            };
          };
        };
      };
      terminal = lib.mkOption {
        type = lib.types.package;
        default = pkgs.ghostty;
        description = "The terminal package to use on this host.";
      };

      mainDevice = lib.mkOption {
        type = lib.types.str;
        description = "The physical disk device path (e.g., ls -l /dev/disk/by-id)";
      };

      tmpfsSize = lib.mkOption {
        type = lib.types.str;
        description = "Size of the tmpfs root filesystem (e.g., '2G' or '25%')";
      };

      bootSize = lib.mkOption {
        type = lib.types.str;
        description = "Size of the EFI boot partition. 1G is standard for modern NixOS to hold multiple generations";
      };

      swapSize = lib.mkOption {
        type = lib.types.str;
        description = "Size of the swapfile allocated inside the BTRFS @swap subvolume, should mostly match RAM size";
      };
    };
  };

  flake.homeModules.host-settings = { lib, config, ... }: {
    options.hostSettings = {
      sshPublicKey = lib.mkOption {
        type = lib.types.str;
        description = "The public SSH key string used by 1Password for Git signing on this host.";
      };
      agentHarness = lib.mkOption {
        type = lib.types.str;
        default = "opencode";
        description = ''
          The agent harness CLI launched in the nic tmux session.

          The value is exported as AGENT_HARNESS via home.sessionVariables
          and read by nic, falling back to opencode where unset.
        '';
      };
      dotfilesDir = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/git/dotfiles";
        description = ''
          Location of the dotfiles repository on this host. Used to derive
          NH_FLAKE for the nh CLI.

          The value is exported through home.sessionVariables, so "$HOME"
          keeps it valid across platforms. Override per host wherever the
          repository is cloned somewhere else.
        '';
      };
      gpgPassphraseRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          1Password secret reference (e.g. "op://Work/GPG/password") holding
          the GPG key passphrase. When set, gpg-agent uses pinentry-1password,
          which asks 1Password for the passphrase on every use.
        '';
      };
      availableSshKeys = lib.mkOption {
        description = "List of available SSH keys for 1Password to make available via the SSH agent";
        default = [ ];
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              item = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "The item name or ID";
              };
              vault = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "The vault name or ID";
              };
              account = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "The account name sign-in address or ID";
              };
            };
          }
        );
      };
    };

    config.home.sessionVariables = {
      AGENT_HARNESS = config.hostSettings.agentHarness;
    };
  };
}

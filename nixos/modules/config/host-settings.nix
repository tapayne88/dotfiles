{
  flake.nixosModules.host-settings = { lib, pkgs, ... }: {
    options.hostSettings = {
      username = lib.mkOption { type = lib.types.str; };
      persistenceMountPath = lib.mkOption {
        type = lib.types.str;
        default = "/persist";
      };
      internalMonitor = lib.mkOption {
        type = lib.types.str;
        default = "";
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

  flake.homeModules.host-settings = { lib, ... }: {
    options.hostSettings = {
      sshPublicKey = lib.mkOption {
        type = lib.types.str;
        description = "The public SSH key string used by 1Password for Git signing on this host.";
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
  };
}

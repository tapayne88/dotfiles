{ self, ... }:
let
  username = "tpayne";
in
{
  flake.nixosModules.framework13ProConfiguration = { pkgs, ... }: {
    imports = [
      # Include the results of the hardware scan.
      self.nixosModules.framework13ProHardware
    ];

    hostSettings = {
      inherit username;
      internalMonitor = "eDP-1";
      terminal = pkgs.ghostty;
      persistenceMountPath = "/persist";
      mainDevice = "/dev/disk/by-id/<find ID>";
      tmpfsSize = "50%";
      bootSize = "1G";
      swapSize = "18G";
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "framework-13-pro";

    # This handles the login screen (if using X11-based DM) and TTY
    services.xserver.xkb = {
      layout = "gb";
      options = "ctrl:nocaps";
    };

    # Force the TTY console to use the same layout as above
    console.useXkbConfig = true;

    home-manager.users."${username}".imports = [
      {
        hostSettings = {
          sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmGM5fgdygjmhCYucEU5zTBUJ8mmlT+Qb2xQkBNRxHx framework-13-pro";
          availableSshKeys = [
            {
              item = "framework-13-pro (default)";
              vault = "Private";
            }
            {
              item = "framework-13-pro (truenas)";
              vault = "Private";
            }
            {
              vault = "Private";
            }
          ];
        };
      }
    ];

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
  };
}

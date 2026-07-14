{
  flake.nixosModules.disko =
    { config, ... }:
    {
      disko.devices = {
        # In-memory tmpfs root
        nodev = {
          "/" = {
            fsType = "tmpfs";
            mountOptions = [
              "size=2G"
              "mode=755"
            ];
          };
        };

        disk = {
          main = {
            device = "/dev/disk/by-id/ata-Samsung_SSD_840_PRO_Series_S12PNEAD137976Z";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                # Boot partition (replaces your /dev/disk/by-uuid/E460-8616)
                ESP = {
                  type = "EF00";
                  size = "511M"; # Matched to the 511M shown in your lsblk output
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "fmask=0022"
                      "dmask=0022"
                    ];
                  };
                };

                # Encrypted partition (replaces /dev/disk/by-uuid/eff69a1e...)
                luks = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    settings = {
                      allowDiscards = true;
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "@persist" = {
                          mountpoint = config.hostSettings.persistenceMountPath;
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "@log" = {
                          mountpoint = "/var/log";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "@swap" = {
                          mountpoint = "/swap";
                          mountOptions = [ "noatime" ];
                          swap = {
                            swapfile = {
                              size = "4096M";
                            };
                          };
                        };
                      };
                    };
                  };
                };

              };
            };
          };
        };
      };

      # Manually flag datasets that are strictly required before the system fully boots
      fileSystems."${config.hostSettings.persistenceMountPath}".neededForBoot = true;
      fileSystems."/var/log".neededForBoot = true;
    };
}

{ inputs, ... }:
{
  flake.nixosModules.disko =
    { config, ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
      ];

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
                # Boot partition
                ESP = {
                  type = "EF00";
                  size = "511M";
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

                # Encrypted partition
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

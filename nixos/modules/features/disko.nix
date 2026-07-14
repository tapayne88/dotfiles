{ inputs, ... }:
{
  flake.nixosModules.disko =
    { config, ... }:
    let
      nixMountPath = "/nix";
      swapMountPath = "/swap";
      logMountPath = "/var/log";
    in
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
              "size=${config.hostSettings.tmpfsSize}"
              "mode=755"
            ];
          };
        };

        disk = {
          main = {
            device = config.hostSettings.mainDevice;
            type = "disk";
            content.type = "gpt";

            # Boot partition
            content.partitions.ESP = {
              type = "EF00";
              size = config.hostSettings.bootSize;
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
            content.partitions.luks = {
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

                  subvolumes."@nix" = {
                    mountpoint = nixMountPath;
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  subvolumes."@persist" = {
                    mountpoint = config.hostSettings.persistenceMountPath;
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  subvolumes."@log" = {
                    mountpoint = logMountPath;
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };

                  subvolumes."@swap" = {
                    mountpoint = swapMountPath;
                    mountOptions = [ "noatime" ];
                    swap = {
                      swapfile = {
                        size = config.hostSettings.swapSize;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };

      swapDevices = [
        {
          device = "${swapMountPath}/swapfile";
          size = 4096;
        }
      ];

      # Manually flag datasets that are strictly required before the system fully boots
      fileSystems."${config.hostSettings.persistenceMountPath}".neededForBoot = true;
      fileSystems."${nixMountPath}".neededForBoot = true;
      fileSystems."${logMountPath}".neededForBoot = true;
    };
}

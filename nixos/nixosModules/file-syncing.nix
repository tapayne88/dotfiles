{ pkgs, config, ... }:
{
  environment.systemPackages = [
    pkgs.syncthingtray
  ];

  services.syncthing = {
    enable = true;
    user = config.hostSettings.username;

    dataDir = "/home/${config.hostSettings.username}";

    openDefaultPorts = true;

    settings = {
      devices = {
        "TrueNAS Server" = {
          id = "R6ZUTLJ-QUH6KAJ-EV3HNUF-ADMHVXJ-JSESUPO-BIWSAJX-A22CPZE-Q2S4QAK";
          addresses = [
            "tcp://100.91.166.76:22000"
          ];

        };
        "Pixel 10 Pro" = {
          id = "6ZC44UX-HUJ2CQW-D4UGB3T-PXHYO7D-PEWKYSQ-W5MKVWF-FJXNH4S-W5V6RQA";
          addresses = [
            "tcp://100.91.166.76:22000"
          ];
        };
      };

      folders = {
        "documents" = {
          id = "qhmqd-qr7sd";
          path = "~/Documents";
          devices = [
            "TrueNAS Server"
          ];
        };
        "notes" = {
          id = "fjfwa-murfe";
          path = "~/Notes";
          devices = [
            "TrueNAS Server"
            "Pixel 10 Pro"
          ];
        };
      };

      options = {
        localAnnounceEnabled = false;
        relaysEnabled = false;
      };
    };
  };
}

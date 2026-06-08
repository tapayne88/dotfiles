{ pkgs, lib, ... }:

let
  truenasServer = "//truenas.home.tompaynesbones.com";

  shares = [
    {
      name = "Media";
      share = "Media";
    }
    {
      name = "Paperless";
      share = "Paperless Consume";
    }
    {
      name = "Photography";
      share = "Photography";
    }
    {
      name = "n8n";
      share = "n8n data";
    }
  ];

  prewarmCommands = builtins.concatStringsSep "\n" (
    map (share: ''
      echo "Refreshing systemd unit for: ${share.name}"
      # If a mount is stuck or a zombie, resetting the native systemd unit 
      # clears it cleanly without breaking the automount listener trap.
      ${pkgs.systemd}/bin/systemctl try-restart "mnt-truenas-${share.name}.mount" || true
      ${pkgs.systemd}/bin/systemctl start "mnt-truenas-${share.name}.mount" || true
    '') shares
  );

  getMountPath = share: "/mnt/truenas/${lib.strings.toLower share.name}";

  commonMountOptions = name: [
    # --- Core Mounting & Security ---
    "x-systemd.automount"
    "noauto"
    "credentials=/etc/nixos/smb-secrets"
    "_netdev"

    # --- Permissions ---
    "uid=1000"
    "gid=100"

    # --- Aggressive Reliability & Fail-Safes ---
    "soft"
    "x-systemd.mount-timeout=5s"
    "x-systemd.device-timeout=5s"

    # --- Icon and UI Metadata ---
    "x-gvfs-show"
    "x-gvfs-name=${name}"
    "x-gvfs-symbolic-icon=network-server"
  ];
in
{
  services.gvfs.enable = true;

  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems = builtins.listToAttrs (
    map (share: {
      name = getMountPath share;
      value = {
        device = "${truenasServer}/${share.share}";
        fsType = "cifs";
        options = commonMountOptions share.name;
      };
    }) shares
  );

  systemd.services.prewarm-truenas = {
    description = "Trigger NAS automounts on boot and wake from sleep";

    # Tell systemd to fire this during boot AND when resuming from sleep
    after = [
      "network-online.target"
      "post-resume.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [
      "multi-user.target"
      "post-resume.target"
    ];

    serviceConfig = {
      Type = "oneshot";
      # Before we touch the folders, we force-unmount any zombie/stale links
      # from before the sleep cycle, then cleanly wake them back up.
      ExecStart = pkgs.writeShellScript "prewarm-script" ''
        ${prewarmCommands}
      '';
      TimeoutStartSec = "10";
      # We remove RemainAfterExit so systemd is allowed to re-run this
      # every single time you open your laptop lid.
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "nas-wifi-tether" ''
        if [ "$2" = "up" ]; then
          ${pkgs.util-linux}/bin/logger -t "NAS-Dispatcher" "Network up. Activating mounts..."
          /run/current-system/sw/bin/systemctl start prewarm-truenas.service
        fi

        if [ "$2" = "down" ] || [ "$2" = "pre-down" ]; then
          ${pkgs.util-linux}/bin/logger -t "NAS-Dispatcher" "Network down. Stopping mounts..."
          /run/current-system/sw/bin/systemctl stop "mnt-truenas-*.mount" || true
        fi
      '';
    }
  ];
}

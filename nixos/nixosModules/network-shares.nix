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
      echo "User-space glance to trigger the kernel autofs trap for: ${getShareName share}"
      ${pkgs.coreutils}/bin/stat ${getMountPath share}/ >/dev/null 2>&1 || true
    '') shares
  );

  getShareName = share: lib.strings.toLower share.name;
  getMountPath = share: "/mnt/truenas/${getShareName share}";

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
    "x-systemd.mount-timeout=10s"
    "x-systemd.device-timeout=10s"

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

  systemd.user.services.prime-truenas-shares = {
    description = "Quietly prime TrueNAS automounts on graphical session startup";

    # NixOS flattens these directly onto the service, no Unit or Install blocks needed
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ]; # Lowercase 'w', sitting at the top level

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "prime-shares" ''
        ${prewarmCommands}
      ''}";
    };
  };
}

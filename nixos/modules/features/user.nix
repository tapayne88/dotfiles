{
  flake.nixosModules.user =
    { pkgs, config, ... }:
    let
      username = config.hostSettings.username;
    in
    {
      # Set your time zone.
      time.timeZone = "Europe/London";

      nix.settings.trusted-users = [
        "root"
        "@wheel"
      ];

      users.users.root.hashedPasswordFile = "${config.hostSettings.persistenceMountPath}/passwords/root";

      # Ensure user directory is present on boot. This is required with impermance and setting up a new machine
      systemd.tmpfiles.rules = [
        "d /persist/home/${username} 0700 ${username} users -"
      ];

      users.users."${config.hostSettings.username}" = {
        hashedPasswordFile = "${config.hostSettings.persistenceMountPath}/passwords/${config.hostSettings.username}";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        packages = [ ];
        shell = pkgs.zsh;
      };
    };
}

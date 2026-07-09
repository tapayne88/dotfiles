{
  flake.nixosModules.user =
    { pkgs, config, ... }:
    {
      # Set your time zone.
      time.timeZone = "Europe/London";

      users.users.root.hashedPasswordFile = "${config.hostSettings.persistenceMountPath}/passwords/root";

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

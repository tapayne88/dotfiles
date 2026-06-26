{ pkgs, config, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users.root.hashedPasswordFile = "/persist/passwords/root";

  users.users."${config.hostSettings.username}" = {
    hashedPasswordFile = "/persist/passwords/${config.hostSettings.username}";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = [ ];
    shell = pkgs.zsh;
  };
}

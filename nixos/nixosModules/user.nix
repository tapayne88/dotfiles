{ pkgs, config, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users."${config.hostSettings.username}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = [ ];
    shell = pkgs.zsh;
  };
}

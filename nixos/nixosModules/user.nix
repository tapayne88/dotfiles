{ pkgs, username, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = [ ];
    shell = pkgs.zsh;
  };
}

{ pkgs, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users.tom = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    packages = [ ];
    shell = pkgs.zsh;
  };
}

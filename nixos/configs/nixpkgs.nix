{ lib, ... }:

let
  allowUnfree =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "1password-gui"
      "1password"
      "terraform"
    ];
in
{
  nixpkgs.config.allowUnfreePredicate = allowUnfree;
}

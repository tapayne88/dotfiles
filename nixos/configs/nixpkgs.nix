{ lib, ... }:

let
  allowUnfree = pkg:
    builtins.elem (lib.getName pkg) [
      "1password-cli"
      "1password-gui"
      "1password"
    ];
in
{
  nixpkgs.config.allowUnfreePredicate = allowUnfree;
}

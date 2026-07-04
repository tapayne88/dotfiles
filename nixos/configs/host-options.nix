{ lib, pkgs, ... }: {
  options.hostSettings = {
    username = lib.mkOption { type = lib.types.str; };
    internalMonitor = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    terminal = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
      description = "The terminal package to use on this host.";
    };
  };
}

{ lib, ... }: {
  options.hostSettings = {
    username = lib.mkOption { type = lib.types.str; };
    internalMonitor = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
}

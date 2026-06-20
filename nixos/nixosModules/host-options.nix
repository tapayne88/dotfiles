{ lib, ... }: {
  options.hostSettings = {
    internalMonitor = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
}

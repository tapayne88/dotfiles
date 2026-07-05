{
  # Inject the option definition and predicate rule into the generic modules tree
  flake.homeModules.unfree = { config, lib, ... }: {
    options.allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    config.nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePackages;
  };

  # Do the exact same for NixOS systems
  flake.nixosModules.unfree = { config, lib, ... }: {
    options.allowedUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    config.nixpkgs.config.allowUnfreePredicate =
      pkg: builtins.elem (lib.getName pkg) config.allowedUnfreePackages;
  };
}

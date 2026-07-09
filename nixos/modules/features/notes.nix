{
  flake.homeModules.notes = {
    allowedUnfreePackages = [ "obsidian" ];

    programs.obsidian.enable = true;
  };
}

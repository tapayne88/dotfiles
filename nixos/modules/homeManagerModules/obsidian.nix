{
  flake.homeModules.obsidian = {
    allowedUnfreePackages = [ "obsidian" ];

    programs.obsidian.enable = true;
  };
}

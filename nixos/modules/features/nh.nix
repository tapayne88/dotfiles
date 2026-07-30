{
  flake.nixosModules.nh = {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 3";
    };
  };

  flake.homeModules.nh = {
    programs.nh.enable = true;
  };
}

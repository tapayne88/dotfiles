{
  flake.nixosModules.nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 14d --keep 5";
        # Sets NH_FLAKE via environment.variables (/etc/set-environment,
        # double-quoted so "$HOME" expands). NixOS hosts have no home-level
        # nh module - this previously came from the chezmoi-managed zsh config.
        flake = "${config.hostSettings.dotfilesDir}/nixos";
      };
    };

  flake.homeModules.nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        # Sets NH_FLAKE via home.sessionVariables for darwin/standalone-home
        # hosts. The repo location varies per host, so it comes from
        # hostSettings.dotfilesDir (defaults to ~/git/dotfiles).
        flake = "${config.hostSettings.dotfilesDir}/nixos";
      };
    };
}

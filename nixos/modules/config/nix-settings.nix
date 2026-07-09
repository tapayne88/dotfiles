{
  flake.nixosModules.nix-settings = {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}

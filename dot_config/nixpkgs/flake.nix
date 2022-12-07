{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # TODO: Fix this (don't forget the overlay)
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixgl.url = "github:guibou/nixGL";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixgl, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      overlays = [
        overlay-unstable
        nixgl.overlay
        # inputs.neovim-nightly-overlay.overlay
      ];
    in
    {
      homeConfigurations = {
        # Pixelbook
        "tapayne88@penguin" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              imports = [
                ./modules/home.nix
                ./modules/crostini.nix
                ./modules/linux.nix
                ./modules/neovim.nix
              ];
            }
            {
              home = {
                username = "tapayne88";
                homeDirectory = "/home/tapayne88";
                stateVersion = "22.11";
              };
            }
          ];
        };
        # MacBook Pro (Work)
        "tom.payne@C02G41YZMD6R" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-darwin";
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              imports = [
                ./modules/home.nix
                ./modules/darwin.nix
                ./modules/neovim.nix
                ./modules/work.nix
              ];
            }
            {
              home = {
                username = "tom.payne";
                homeDirectory = "/Users/tom.payne";
                stateVersion = "22.11";
              };
            }
          ];
        };
        # WSL
        "tpayne@DESKTOP-EACCNGB" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              imports = [
                ./modules/home.nix
                ./modules/linux.nix
                ./modules/neovim.nix
              ];
            }
            {
              home = {
                username = "tpayne";
                homeDirectory = "/home/tpayne";
                stateVersion = "22.11";
              };
            }
          ];
        };
      };
    };
}

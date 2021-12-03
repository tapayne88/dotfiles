{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixgl = {
      url = "github:guibou/nixGL";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config = {
            allowUnfree = true;
          };
        };
      };
      overlay-nixgl = final: prev: {
        nixgl = import inputs.nixgl {
          pkgs = inputs.nixpkgs.legacyPackages.${prev.system};
        };
      };
      overlays = [
        overlay-unstable
        overlay-nixgl
        inputs.neovim-nightly-overlay.overlay
      ];
    in
    # legacyPackages attribute for declarative channels (used by compat/default.nix)
    inputs.flake-utils.lib.eachDefaultSystem (system:
    {
      legacyPackages = inputs.nixpkgs.legacyPackages.${system};
    }
    ) //
    {
      homeConfigurations = {
        "tapayne88@penguin" = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/tapayne88";
          username = "tapayne88";
          stateVersion = "21.05";
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = {
                allowUnfree = true;
              };

              imports = [
                ./modules/home.nix
                ./modules/crostini.nix
                ./modules/linux.nix
              ];
            };
        };
        "thomas.payne@SBGML05573" = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-darwin";
          homeDirectory = "/Users/thomas.payne";
          username = "thomas.payne";
          stateVersion = "21.05";
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = {
                allowUnfree = true;
              };

              imports = [
                ./modules/home.nix
                ./modules/darwin.nix
              ];
            };
        };
        # TODO: Setup WSL host
    };
  };
}

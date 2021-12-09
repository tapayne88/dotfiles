{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # TODO: Required for older openssh compatibility with stash
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-21.05";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixgl = {
      url = "github:guibou/nixGL";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      overlay-old = final: prev: {
        old = import inputs.nixpkgs-old {
          system = prev.system;
          config.allowUnfree = true;
        };
      };
      overlay-nixgl = final: prev: {
        nixgl = import inputs.nixgl {
          pkgs = inputs.nixpkgs.legacyPackages.${prev.system};
        };
      };
      overlays = [
        overlay-unstable
        overlay-old
        overlay-nixgl
        inputs.neovim-nightly-overlay.overlay
      ];
    in
    {
      homeConfigurations = {
        # Pixelbook
        "tapayne88@penguin" = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/tapayne88";
          username = "tapayne88";
          stateVersion = "21.11";
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              imports = [
                ./modules/home.nix
                ./modules/crostini.nix
                ./modules/linux.nix
              ];
            };
        };
        # MacBook Pro
        "thomas.payne@SBGML05573" = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-darwin";
          homeDirectory = "/Users/thomas.payne";
          username = "thomas.payne";
          stateVersion = "21.11";
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

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

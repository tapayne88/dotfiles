{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # TODO: Fix this (don't forget the overlay)
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixgl.url = "github:guibou/nixGL";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixgl, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "electron-25.9.0" # crostini - obsidian
          ];
        };
      };
      system_pkgs = system: import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay-unstable
          nixgl.overlay
          # inputs.neovim-nightly-overlay.overlay
        ];
      };
    in
    {
      homeConfigurations = {
        # Pixelbook
        "tapayne88@penguin" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = system_pkgs "x86_64-linux";
          modules = [
            {
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
                stateVersion = "24.11";
              };
            }
          ];
        };
        # MacBook Pro Intel (Work)
        "tom.payne@C02G41YZMD6R" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = system_pkgs "x86_64-darwin";
          modules = [
            {
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
                stateVersion = "24.11";
              };
            }
          ];
        };
        # MacBook Pro M3 (Work)
        "tom.payne@KL2M3W1G4N" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = system_pkgs "aarch64-darwin";
          modules = [
            {
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
                stateVersion = "24.11";
              };
            }
          ];
        };
        # WSL
        "tpayne@DESKTOP-EACCNGB" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = system_pkgs "x86_64-linux";
          modules = [
            {
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
                stateVersion = "24.11";
              };
            }
          ];
        };
      };
    };
}

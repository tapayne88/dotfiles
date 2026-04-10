{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixgl.url = "github:guibou/nixGL";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      system_pkgs = system: import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          overlay-unstable
          nixgl.overlay
        ];
      };
    in
    {
      homeConfigurations = {
        # Pixelbook Omarchy
        "tpayne@omarchy-pixelbook" = inputs.home-manager.lib.homeManagerConfiguration {
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
                stateVersion = "25.05";
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
                stateVersion = "25.05";
              };
            }
          ];
        };
      };
    };
}

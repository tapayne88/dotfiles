{
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs-stable,
      nixpkgs-unstable,
      home-manager,
      stylix,
      ...
    }:
    {
      nixosConfigurations.thinkpad = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = [
          ./configs/nixpkgs.nix
          ./hosts/thinkpad/configuration.nix
          home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.tom = {
                imports = [
                  ./modules/neovim.nix
                  ./modules/shell.nix
                  ./modules/linux.nix
                ];
                home = {
                  username = "tom";
                  homeDirectory = "/home/tom";
                  stateVersion = "25.11";
                };
              };
            };
          }
          stylix.nixosModules.stylix
        ];
      };
      homeConfigurations = {
        # Pixelbook Omarchy
        "tpayne@omarchy-pixelbook" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
          modules = [
            {
              imports = [
                ./configs/nixpkgs.nix
                ./modules/shell.nix
                ./modules/linux.nix
                ./modules/neovim.nix
              ];
            }
            {
              home = {
                username = "tpayne";
                homeDirectory = "/home/tpayne";
                stateVersion = "25.11";
              };
            }
          ];
        };
        # MacBook Pro M3 (Work)
        "tom.payne@KL2M3W1G4N" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin;
          modules = [
            {
              imports = [
                ./configs/nixpkgs.nix
                ./modules/shell.nix
                ./modules/darwin.nix
                ./modules/neovim.nix
                ./modules/work.nix
              ];
            }
            {
              home = {
                username = "tom.payne";
                homeDirectory = "/Users/tom.payne";
                stateVersion = "25.11";
              };
            }
          ];
        };
      };
    };
}

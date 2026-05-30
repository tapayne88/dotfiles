{
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    catppuccin-waybar = {
      url = "github:catppuccin/waybar";
      flake = false;
    };
    catppuccin-wlogout = {
      url = "github:catppuccin/wlogout";
      flake = false;
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    vicinae.url = "github:vicinaehq/vicinae";
  };
  outputs =
    inputs@{
      nixpkgs-unstable,
      home-manager,
      stylix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs-unstable { inherit system; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixfmt-tree
        ];
      };
      nixosConfigurations.thinkpad = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = [
          {
            nix.settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              extra-substituters = [ "https://vicinae.cachix.org" ];
              extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
            };
          }
          ./configs/nixpkgs.nix
          ./hosts/thinkpad/configuration.nix
          ./features/file-browser.nix
          ./features/greeter.nix
          home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
              };
              users.tom = {
                imports = [
                  ./modules/neovim.nix
                  ./modules/shell.nix
                  ./modules/linux.nix

                  ./features/browser.nix
                  ./features/hyprland.nix
                  ./features/programs.nix
                  ./features/vicinae.nix
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

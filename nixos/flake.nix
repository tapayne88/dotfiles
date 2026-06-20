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

    tuigreet-fork.url = "github:notashelf/tuigreet";
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
              trusted-users = [
                "root"
                "@wheel"
              ];
            };
          }

          stylix.nixosModules.stylix
          home-manager.nixosModules.default

          ./configs/host-options.nix
          ./configs/nixpkgs.nix
          ./hosts/thinkpad/configuration.nix
          ./nixosModules
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
                ./homeManagerModules/shell.nix
                ./homeManagerModules/linux.nix
                ./homeManagerModules/neovim.nix
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
                ./homeManagerModules/shell.nix
                ./homeManagerModules/darwin.nix
                ./homeManagerModules/neovim.nix
                ./homeManagerModules/work.nix
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

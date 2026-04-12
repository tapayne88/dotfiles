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
  outputs = inputs@{ self, nixpkgs-unstable, home-manager, stylix, ... }: {
    nixosConfigurations.thinkpad = nixpkgs-unstable.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };

      modules = [ 
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
              ];
              home = {
                username = "tom";
                homeDirectory = "/home/tom";
                stateVersion = "26.05";
              };
            };
          };
        }
        stylix.nixosModules.stylix
      ];
    };
  };
}


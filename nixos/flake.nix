{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, stylix, ... }: {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
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
                ./home/tom.nix
                ./modules/neovim.nix
              ];
            };
          };
        }
        stylix.nixosModules.stylix
      ];
    };
  };
}


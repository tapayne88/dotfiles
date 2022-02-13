{
  description = "My NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager }:
    let
      system = "x86_64-linux";

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
	  system = prev.system;
	  config.allowUnfree = true;
	};
      };
      overlays = [
        overlay-unstable
      ];
    in {
      nixosConfigurations.thinkpad-nixos = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
	  ({ config, pkgs, ... }: {
	    nixpkgs.overlays = overlays;
	    nixpkgs.config.allowUnfree = true;
	  })
	  home-manager.nixosModules.home-manager {
	    home-manager.useGlobalPkgs = true;
	  }
	  ./configuration.nix
	];
      };
    };
}

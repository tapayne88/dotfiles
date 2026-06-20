{ inputs, config, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };
    users."${config.hostSettings.username}" = {
      imports = [
        ../homeManagerModules/neovim.nix
        ../homeManagerModules/shell.nix
        ../homeManagerModules/linux.nix

        ../features/browser.nix
        ../features/hyprland.nix
        ../features/obsidian.nix
        ../features/programs.nix
        ../features/vicinae.nix
      ];
      home = {
        username = config.hostSettings.username;
        homeDirectory = "/home/${config.hostSettings.username}";
        stateVersion = "25.11";
      };
    };
  };
}

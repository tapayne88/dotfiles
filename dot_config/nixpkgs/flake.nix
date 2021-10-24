{
  description = "Home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixgl = {
      url = "github:guibou/nixGL";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;
          config = {
            allowUnfree = true;
          };
        };
      };
      overlays = [
        overlay-unstable
        inputs.neovim-nightly-overlay.overlay
      ];
    in
    # legacyPackages attribute for declarative channels (used by compat/default.nix)
    inputs.flake-utils.lib.eachDefaultSystem (system:
    {
      legacyPackages = inputs.nixpkgs.legacyPackages.${system};
    }
    ) //
    {
      homeConfigurations = {
        tapayne88 = inputs.home-manager.lib.homeManagerConfiguration {
          system = "x86_64-linux";
          homeDirectory = "/home/tapayne88";
          username = "tapayne88";
          configuration = { pkgs, ... }:
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config = {
                allowUnfree = true;
              };

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
              
              home.packages = with pkgs; [
                gcc # neovim - building nvim-treesitter parsers
                nq  # linux queue utility

                antigen                       # zsh plugin manager
                asciinema                     # asciinema.org recorder
                awscli2                       # cli for working with aws
                bat                           # colourised cat
                chezmoi                       # dotfile manager
                ctop                          # container top process tool
                curl                          # curl...
                fpp                           # facebook picker
                fzf                           # fuzzy-finder
                gawk                          # gnu awk
                gitAndTools.diff-so-fancy     # fancy git diffs
                git                           # git...
                gnupg                         # gnu pretty good privacy
                gti                           # alias for git, with a gti
                htop                          # pretty top
                inetutils                     # network utils, like traceroute, etc.
                jq                            # json cli processor
                kubectx                       # nicer interaction with k8s cli
                mosh                          # better ssh
                ncdu                          # disk usage tool
                netcat                        # netcat implementaion
                nodejs                        # nodejs...
                openssh                       # ssh
                python3                       # python38
                python38Packages.pip          # pip for python38
                ripgrep                       # rg searching
                silver-searcher               # ag searching
                neofetch                      # pretty print of system info
                ruby                          # always useful to have ruby
                tmuxp                         # declaritive tmux session launcher
                tree                          # print directory structure
                up                            # utlimate plumber - unix pipes tool
                unixtools.watch               # run command periodically
                vim                           # vim
                watchman                      # watch files and run command on change
                wget                          # fetch things from urls
                yarn                          # JS package manager
                zsh                           # shell

                # Unstable Packages
                unstable._1password   # 1password version is quite old - unstable is much newer
                unstable.tmux         # terminal multiplexer
              ];


              programs.neovim = {
                enable = true;
                viAlias = true;
                withNodeJs = true;

                # Neovim nightly
                package = pkgs.neovim-nightly;
              };
            };
        };
    };
    cfg = self.homeConfigurations.tapayne88.activationPackage;
    defaultPackage.x86_64-linux = self.cfg;
  };
}

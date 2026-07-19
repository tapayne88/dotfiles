{
  flake.homeModules.shell =
    {
      config,
      pkgs,
      pkgs-unstable,
      ...
    }:
    let
      # MacOS defaults to stable, nixos defaults to unstable. This is an explicit
      # list of unstable packages so macOS can get them
      unstablePkgs = with (if pkgs.stdenv.isDarwin then pkgs-unstable else pkgs); [
        _1password-cli
        carapace # A multi-shell completion library
        git # newest git!
        jqp # TUI playground for jq
        k9s # Kubernetes CLI To Manage Your Clusters In Style!
        kubie # even nicer interaction with k8s cli with multiple configs
        lazygit # simple terminal UI for git commands
        television # A very fast, portable and hackable fuzzy finder.
        tldr # simplified and community-driven man pages
        tmux # terminal multiplexer
        worktrunk # Git worktree manager for parallel AI agent workflows
      ];
    in
    {
      allowedUnfreePackages = [ "1password-cli" ];

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      programs.zsh = {
        enable = true;

        initContent = ''
          source ${pkgs.antigen}/share/antigen/antigen.zsh

          if [ -f ${config.xdg.configHome}/zsh/config ]; then
            source ${config.xdg.configHome}/zsh/config
          fi
        '';
      };

      home.packages =
        with pkgs;
        [
          atuin # Magical shell history
          bat # colourised cat
          chezmoi # dotfile manager
          curl # curl...
          delta # better git diffs
          dig # dns lookup
          direnv # Shell extension that manages your environment
          duf # pretty alternative to df
          eza # ls replacement
          fd # faster more user friendly find
          fzf # fuzzy-finder
          gti # alias for git, with a gti
          just # Handy way to save and run project-specific commands
          jq # json cli processor
          mise # Front-end to your dev env
          ripgrep # rg searching
          vivid # A themeable LS_COLORS generator with a rich filetype datebase
          zoxide # A smarter cd command
        ]
        ++ unstablePkgs;

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 3";
      };

      programs.btop = {
        enable = true;
        settings = {
          vim_keys = true;
        };
      };
    };
}

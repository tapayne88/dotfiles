{
  flake.homeModules.shell =
    {
      config,
      pkgs,
      pkgs-unstable,
      lib,
      ...
    }:
    let
      # MacOS defaults to stable, nixos defaults to unstable. This is an explicit
      # list of unstable packages so macOS can get them
      unstablePkgs = with (if pkgs.stdenv.hostPlatform.isDarwin then pkgs-unstable else pkgs); [
        _1password-cli
        carapace # A multi-shell completion library
        jqp # TUI playground for jq
        k9s # Kubernetes CLI To Manage Your Clusters In Style!
        kubie # even nicer interaction with k8s cli with multiple configs
        lazygit # simple terminal UI for git commands
        television # A very fast, portable and hackable fuzzy finder.
        tldr # simplified and community-driven man pages
        tmux # terminal multiplexer
        worktrunk # Git worktree manager for parallel AI agent workflows
      ];

      gitPkg = if pkgs.stdenv.hostPlatform.isDarwin then pkgs-unstable.git else pkgs.git;

      _1passwordSock =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        else
          "${config.home.homeDirectory}/.1password/agent.sock";

      tomlFormat = pkgs.formats.toml { };
    in
    {
      allowedUnfreePackages = [
        "1password-cli"
        "1password"
      ];

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      programs.zsh = {
        enable = true;

        initContent = ''
          source ${pkgs.antigen}/share/antigen/antigen.zsh

          if [ -f ${config.xdg.configHome}/zsh/config ]; then
            source ${config.xdg.configHome}/zsh/config
          fi

          export SSH_AUTH_SOCK="${_1passwordSock}"
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
          gh # GitHub CLI tool
          gti # alias for git, with a gti
          just # Handy way to save and run project-specific commands
          jq # json cli processor
          mise # Front-end to your dev env
          ripgrep # rg searching
          rustup
          vivid # A themeable LS_COLORS generator with a rich filetype datebase
          zoxide # A smarter cd command
        ]
        ++ unstablePkgs;

      programs.btop = {
        enable = true;
        settings = {
          vim_keys = true;
        };
      };

      programs.git = {
        enable = true;
        package = gitPkg;

        includes = [
          {
            path = "${config.xdg.configHome}/git/default";
          }
          {
            condition = "gitdir:work/";
            path = "${config.xdg.configHome}/git/work";
          }
          {
            path = "${config.xdg.configHome}/git/extra";
          }
        ];

        signing =
          let
            signer =
              if pkgs.stdenv.hostPlatform.isDarwin then
                "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
              else
                "${pkgs._1password-gui}/bin/op-ssh-sign";
          in
          {
            inherit signer;
            format = "ssh";
            key = config.hostSettings.sshPublicKey;
            signByDefault = true;
          };
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ "shared_config" ];
        settings = {
          "*" = {
            IdentityAgent = ''"${_1passwordSock}"'';
          };
        };
      };

      xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (config.hostSettings.availableSshKeys != [ ]) {
        source = tomlFormat.generate "agent.toml" {
          # 2. `builtins.filter` removes any dictionaries that ended up completely empty `{}`
          ssh-keys = builtins.filter (attrs: attrs != { }) (
            # 1. `map` and `filterAttrs` strip out keys where the value is `null` OR `{}`
            map (
              keyAttrs: lib.filterAttrs (name: value: value != null) keyAttrs
            ) config.hostSettings.availableSshKeys
          );
        };
      };
    };
}

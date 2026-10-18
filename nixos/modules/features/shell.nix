{ inputs, ... }:
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
        inputs.treehouse.packages.${pkgs.stdenv.hostPlatform.system}.default # Manage worktrees without managing worktrees
        worktrunk # Git worktree manager for parallel AI agent workflows
      ];

      gitPkg = if pkgs.stdenv.hostPlatform.isDarwin then pkgs-unstable.git else pkgs.git;

      _1passwordSock =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        else
          "${config.home.homeDirectory}/.1password/agent.sock";

      tomlFormat = pkgs.formats.toml { };

      # LS colors generated once at build time instead of forking vivid on
      # every shell startup
      lsColors = pkgs.runCommand "ls-colors-catppuccin-mocha" {
        nativeBuildInputs = [ pkgs.vivid ];
      } "vivid generate catppuccin-mocha > $out";
    in
    {
      allowedUnfreePackages = [
        "1password-cli"
        "1password"
      ];

      # Let Home Manager install and manage itself.
      programs.home-manager.enable = true;

      # Exports the XDG_* environment variables (previously done manually in
      # initContent) via hm-session-vars, sourced from .zshenv/.zprofile so
      # non-interactive shells and systemd user services see them too
      xdg.enable = true;

      # Bat as manpager, sourced from .zshenv/.zprofile so man works from any
      # shell context (not just interactive zsh). VISUAL/EDITOR are already set
      # by programs.neovim.defaultEditor via the same mechanism
      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };

      # Prepended to PATH (list order = front of PATH first), rendered in a
      # double-quoted export so "$HOME" expands. Replaces the prepend_path
      # function from the chezmoi-managed zsh config. ~/.local/bin is first so
      # local scripts override nix and homebrew. NOTE: xdg.localBinInPath is
      # deliberately not used - it appends via mkAfter, which would put
      # ~/.local/bin behind the homebrew entries
      home.sessionPath = [
        "$HOME/.local/bin"
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        "/opt/homebrew/bin"
        "/usr/local/bin"
      ];

      programs.zsh = {
        enable = true;
        dotDir = config.home.homeDirectory;

        history = {
          size = 50000;
          save = 50000;
        };

        autosuggestion = {
          enable = true;
          # Left unset so atuin can define it (it prepends its own strategy)
          strategy = [ ];
        };

        syntaxHighlighting = {
          enable = true;
          highlighters = [ "brackets" ];
          styles = {
            default = "fg=cyan";
            commandseparator = "fg=magenta";
            command = "fg=white";
            precommand = "fg=yellow";
            builtin = "fg=white";
            alias = "fg=white";
            function = "fg=white";
            globbing = "fg=yellow";
            arg0 = "fg=cyan";
            single-hyphen-option = "fg=cyan";
            double-hyphen-option = "fg=cyan";
            path = "fg=cyan,underline";
            redirection = "fg=blue";
            command-substitution = "fg=white";
            back-quoted-argument = "fg=white";
            command-substitution-delimiter = "fg=yellow";
            process-substitution-delimiter = "fg=yellow";
            back-quoted-argument-unclosed = "fg=red";
            single-quoted-argument-unclosed = "fg=red";
            double-quoted-argument-unclosed = "fg=red";
            dollar-quoted-argument-unclosed = "fg=red";
            bracket-error = "fg=red";
            bracket-level-1 = "fg=yellow";
            bracket-level-2 = "fg=yellow";
            bracket-level-3 = "fg=yellow";
            bracket-level-4 = "fg=yellow";
            cursor-matchingbracket = "bg=black";
          };
        };

        # NOTE: zsh-vi-mode is NOT in `plugins` on purpose. It must be sourced
        # AFTER zsh-syntax-highlighting (which home-manager fixes at order
        # 1200) so it can wrap all widgets, so it is sourced manually at order
        # 1250 below.
        plugins = [
          {
            name = "zsh-completions";
            src = pkgs.zsh-completions;
          }
          {
            name = "forgit";
            src = pkgs.zsh-forgit;
            file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
          }
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];

        oh-my-zsh = {
          enable = true;
          plugins = [
            "common-aliases"
            "direnv"
            "docker"
            "fzf"
            "kubectl"
            "terraform"
            "tmux"
          ];
        };

        localVariables = {
          DEFAULT_USER = config.home.username;
          WORDCHARS = "";
        };

        setOptions = [
          "AUTO_MENU"
          "COMPLETE_IN_WORD"
          "ALWAYS_TO_END"
          "NO_MENU_COMPLETE"
          "NO_FLOWCONTROL"
        ];

        shellAliases = {
          ls = "eza --group-directories-first --icons always";
          l = "ls --long --classify=\"always\" --header";
          la = "ls --long --all";
          lt = "ls --tree";
          ll = "ls --long";
          lg = "ls --long --git";
          ldot = "ls --long --list-dirs .*";
          lrt = "ls --long --classify=\"always\" --reverse --time=\"modified\" --header";
          lvi = "NVIM_APPNAME=LazyVim nvim";
        };

        # SSH_AUTH_SOCK belongs in .zshenv so non-interactive shells (editors,
        # scripts) can also reach the 1Password agent
        envExtra = ''
          export SSH_AUTH_SOCK="${_1passwordSock}"
        ''
        # macOS has no system-level nix shell integration (NixOS uses
        # /etc/zshenv; this mac's /etc/paths.d has no nix entry), so source
        # nix.sh like the pre-nix zsh config did. Puts the nix and
        # home-manager profile bins on PATH and sets NIX_PROFILES, which the
        # fpath loop in the generated .zshrc needs for completions.
        # hm-session-vars.sh needs no manual sourcing - home-manager adds
        # that itself when it manages the shell
        + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
            . "$HOME/.nix-profile/etc/profile.d/nix.sh"
          elif [ -e /nix/var/nix/profiles/default/etc/profile.d/nix.sh ]; then
            . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
          fi

          # envExtra runs after home.sessionPath, and nix.sh prepends to
          # PATH, so re-assert ~/.local/bin at the front to preserve
          # local-script overrides
          if [ -d "$HOME/.local/bin" ]; then
            export PATH="$HOME/.local/bin:$PATH"
          fi
        '';

        # zshrc ordering used below:
        #   550  before oh-my-zsh (800) and plugin sourcing (900)
        #   850  after compinit (run by oh-my-zsh) but before zsh-vi-mode
        #   1000 general configuration (default)
        #   1250 after zsh-syntax-highlighting (1200), loads zsh-vi-mode
        #   1500 last (mkAfter)
        initContent = lib.mkMerge [
          (lib.mkOrder 550 ''
            # oh-my-zsh tmux plugin
            if [ "$TERM" = 'xterm-ghostty' ]; then
              # Autostart tmux
              export ZSH_TMUX_AUTOSTART=true
            fi
            export ZSH_TMUX_AUTOQUIT="false"
            export ZSH_TMUX_AUTOCONNECT="false"

            # fzf defaults
            export FZF_TMUX_OPTS="-d 40%"

            export FZF_CTRL_T_OPTS="\
              --preview 'bat --style=numbers --color=always {} | head -500' \
              --bind='?:toggle-preview' \
            "

            export FZF_DEFAULT_OPTS="\
              --layout reverse \
              --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down \
              --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
              --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
              --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
              --color=selected-bg:#45475A \
              --color=border:#313244,label:#CDD6F4"

            # Disable default aliases like glo
            export FORGIT_NO_ALIASES=true
          '')

          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
            lib.mkOrder 550 ''
              # Register gls alias to trick oh-my-zsh into thinking we've installed
              # coreutils through homebrew (actually installed with nix). This way
              # we get nice ls color support
              alias gls='ls'
            ''
          ))

          # atuin must init before zsh-vi-mode (sourced at order 1250) so the
          # widgets it defines exist when zvm_after_init rebinds ^R
          (lib.mkOrder 850 ''
            eval "$(atuin init zsh)"

            function zvm_config() {
              ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
            }

            function zvm_after_init() {
              # Workaround to make vi-mode work with atuin
              zvm_bindkey viins '^R' atuin-search
              zvm_bindkey vicmd '^R' atuin-search
            }
          '')

          ''
            # Disables scroll lock shortcut (Ctrl+s)
            [[ -t 0 ]] && stty -ixon

            # Completions
            zmodload -i zsh/complist
            zstyle ':completion:*:*:*:*:*' menu select
            bindkey -M menuselect '^o' accept-and-infer-next-history

            # Case insensitive completion (adjust based on your preference)
            zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

            # Complete . and .. special directories
            zstyle ':completion:*' special-dirs true

            # Process completion with colors
            zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
            if [[ "$OSTYPE" = solaris* ]]; then
              zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
            else
              zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
            fi

            # Prioritize local directories for cd completion
            zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

            # Enable completion caching
            zstyle ':completion:*' use-cache yes
            zstyle ':completion:*' cache-path ~/.cache/zsh

            # Don't complete uninteresting system users
            zstyle ':completion:*:*:*:users' ignored-patterns \
              adm amanda apache at avahi avahi-autoipd beagledidx bin cacti canna \
              clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
              gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
              ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
              named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
              operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
              rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
              usbmux uucp vcsa wwwrun xfs '_*'

            # Show ignored matches if they are the only option
            zstyle '*' single-ignored show

            # Load bash completion compatibility
            autoload -U +X bashcompinit && bashcompinit

            # Setup carapace after compinit to ensure it can override existing completions
            export CARAPACE_BRIDGES='zsh,inshellisense'
            export CARAPACE_MATCH=1
            source <(carapace _carapace)

            # forgit config
            # configure checkout_branch to sort by most recent commit
            export FORGIT_CHECKOUT_BRANCH_BRANCH_GIT_OPTS='--sort=-committerdate'

            # PNPM global install path
            export PNPM_HOME="$HOME/.local/share/pnpm"
            case ":$PATH:" in
              *":$PNPM_HOME:"*) ;;
              *) export PATH="$PNPM_HOME:$PATH" ;;
            esac

            export LS_COLORS="$(cat ${lsColors})"
            # Need to run this after carapace setup to ensure colors are preserved
            zstyle ':completion:*' list-colors "''${(@s.:.)LS_COLORS}"
            zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

            # ensure ssh server has terminfo for env TERM
            function ssh() {
              emulate -L zsh

              TERM=xterm-256color command ssh "$@"
            }

            # Idempotent tmux startup function
            function tm() {
              if [ "$1" = "-h" ]; then
                echo "tm - create new tmux session, or switch to existing one. Also kill"
                echo ""
                echo "Usage:"
                echo "   tm <flags> <session>"
                echo ""
                echo "Flags:"
                echo "   -h     Help, print his help message"
                echo "   -k     Kill named session or using fzf"
                echo ""
                echo "\`tm\` will allow you to select your tmux session via fzf."
                echo "\`tm irc\` will attach to the irc session (if it exists), else it will create it."
                return
              fi

              [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"

              # destroy flag
              if [ "$1" = "-k" ]; then
                change="kill-session"
                if [ $2 ]; then
                  tmux $change -t $2; return
                fi
              elif [ "$1" ]; then
                tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t $1); return
              fi

              session=$(tmux list-sessions 2>/dev/null | fzf --height 15 --header $change | cut -f 1 -d':') && [ $session ] && tmux $change -t "$session" || echo "No sessions found."
            }

            # a wrapper function for tmux plugin manager commands
            function tpm() {
              if [ "$1" = "-h" ]; then
                echo "NAME"
                echo "   tpm - a wrapper function for tmux plugin manager commands"
                echo ""
                echo "SYNOPSIS"
                echo "   tm [-h | install | update <plugin-name> | clean]"
                echo ""
                echo "OPTIONS"
                echo "   -h"
                echo "       Help, print his help message"
                echo ""
                echo "   install"
                echo "       Install all configured plugins (in .tmux.conf)"
                echo ""
                echo "   update [all | <plugin-name>]"
                echo "       Update all or <plugin-name> plugin"
                echo ""
                echo "   clean"
                echo "       Removed all non configured plugins"
                return
              fi

              if [ "$1" = "install" ]; then
                ''${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/install_plugins
                return
              fi
              if [ "$1" = "update" ]; then
                ''${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/update_plugins ''${2:=all}
                return
              fi
              if [ "$1" = "clean" ]; then
                ''${TMUX_PLUGIN_MANAGER_PATH}tpm/bin/clean_plugins
                return
              fi
            }

            ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
              # `brew` wrapper:
              #   - `brew upgrade` = upgrade brew installed formula and bundle
              #   - `brew ARG` = behave as normal
              function brew() {
                if [ "$1" = upgrade ]; then
                  set -x
                  command brew upgrade
                  command brew bundle install --global
                else
                  command brew "$@"
                fi
              }
            ''}

            if [ -e ~/.zshrc.local ]; then
              source ~/.zshrc.local
            fi
          ''

          (lib.mkOrder 1250 ''
            # Load zsh-vi-mode after zsh-syntax-highlighting (order 1200) so it
            # can wrap all widgets. Calls the zvm_after_init hook defined above
            # to rebind ^R to atuin in the vi keymaps.
            source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
          '')

          (lib.mkOrder 1500 ''
            # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

            if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
          '')
        ];
      };

      programs.atuin = {
        enable = true;
        # Integration is initialised manually at initContent order 850 so the
        # widgets exist before zsh-vi-mode rebinds ^R via zvm_after_init
        enableZshIntegration = false;
        forceOverwriteSettings = true;
        settings = {
          dialect = "uk";
          style = "compact";
          inline_height = 20;
          enter_accept = true;
          keymap_mode = "auto";
          theme.name = "catppuccin-mocha-lavender";
          sync.records = true;
        };
        themes."catppuccin-mocha-lavender" = {
          theme.name = "catppuccin-mocha-lavender";
          colors = {
            AlertInfo = "#a6e3a1";
            AlertWarn = "#fab387";
            AlertError = "#f38ba8";
            Annotation = "#b4befe";
            Base = "#cdd6f4";
            Guidance = "#9399b2";
            Important = "#f38ba8";
            Title = "#b4befe";
          };
        };
      };

      programs.zoxide.enable = true;

      programs.mise.enable = true;

      home.packages =
        with pkgs;
        [
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
          ripgrep # rg searching
          rustup
          vivid # A themeable LS_COLORS generator with a rich filetype datebase
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

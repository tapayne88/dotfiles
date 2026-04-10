{ config, pkgs, ... }:

{
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    extraConfig = ''
      let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'

      luafile ${config.xdg.configHome}/nvim/init-lua.lua
    '';
  };

  programs.zsh = {
    enable = true;

    # TODO: Fix deprecation warning
    dotDir = ".config/zsh";

    initContent = ''
      source ${pkgs.antigen}/share/antigen/antigen.zsh

      if [ -f ~/.zshrc ]; then
        source ~/.zshrc
      fi
    '';
  };

  home.packages = with pkgs; [
    # neovim utils
    gcc
    gnumake
    binutils
    lua
    luaPackages.luarocks
    tree-sitter # nvim-treesitter dependency

    # lsp
    bazel-buildtools
    hadolint
    helm-ls
    lua-language-server
    sqlfluff
    ruff
    stylua
    markdownlint-cli
    prettierd
    bash-language-server
    # cucumber_language_server
    eslint_d
    python314Packages.python-lsp-server
    terraform-ls
    vtsls
    jsonnet-language-server
    vscode-json-languageserver
    yaml-language-server

    antigen # zsh plugin manager
    atuin # Magical shell history
    bat # colourised cat
    delta # better git diffs
    eza # ls replacement
    fd # faster more user friendly find
    fzf # fuzzy-finder
    gti # alias for git, with a gti
    jq # json cli processor
    ripgrep # rg searching
    vivid # A themeable LS_COLORS generator with a rich filetype datebase
    zoxide # A smarter cd command

    # unstable
    carapace # A multi-shell completion library
    git # newest git!
    jqp # TUI playground for jq
    k9s # Kubernetes CLI To Manage Your Clusters In Style!
    kubie # even nicer interaction with k8s cli with multiple configs
    lazygit # simple terminal UI for git commands
    television # A very fast, portable and hackable fuzzy finder.
    tmux # terminal multiplexer
  ];

  home.stateVersion = "26.05";
}

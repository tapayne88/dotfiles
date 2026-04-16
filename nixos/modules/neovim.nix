{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # tree-sitter + dependency
    gnumake
    lua
    luaPackages.luarocks
    tree-sitter

    # lsp
    bash-language-server
    bazel-buildtools
    # cucumber_language_server
    eslint_d
    hadolint
    helm-ls
    jsonnet-language-server
    lua-language-server
    markdownlint-cli
    nixd
    nixfmt
    prettierd
    python314Packages.python-lsp-server
    ruff
    shellcheck
    sqlfluff
    stylua
    terraform-ls
    vscode-langservers-extracted
    vtsls
    yaml-language-server
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    withRuby = false;
    withPython3 = false;
    extraConfig = ''
      let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/${
        if pkgs.stdenv.isDarwin then "libsqlite3.dylib" else "libsqlite3.so"
      }'

      luafile ${config.xdg.configHome}/nvim/init-lua.lua
    '';
  };
}

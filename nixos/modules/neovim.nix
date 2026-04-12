{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # tree-sitter + dependency
    gnumake
    lua
    luaPackages.luarocks
    tree-sitter

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
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    extraConfig = ''
      let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/${
        if pkgs.stdenv.isDarwin
        then "libsqlite3.dylib"
        else "libsqlite3.so"
      }'

      luafile ${config.xdg.configHome}/nvim/init-lua.lua
    '';
  };
}

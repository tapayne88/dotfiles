function nix-update() {
  set -x
  nix-channel --update
  nix-env -u
  home-manager switch

  # bug with nix neovim config writes init.vim which conflicts with my init.lua
  # https://github.com/nix-community/home-manager/issues/1907
  rm -rf $XDG_CONFIG_HOME/nvim/init.vim
}

function nix-clean() {
  set -x
  local DEFAULT_MAX_AGE_DAYS="30"

  home-manager expire-generations "-${1:-$DEFAULT_MAX_AGE_DAYS} days"
  nix-env --delete-generations "${1:-$DEFAULT_MAX_AGE_DAYS}d"
}

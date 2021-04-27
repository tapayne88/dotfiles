function nix-update() {
  set -x
  nix-channel --update
  nix-env -u
  home-manager switch
}

function nix-clean() {
  set -x
  local DEFAULT_MAX_AGE_DAYS="30"

  home-manager expire-generations "-${1:-$DEFAULT_MAX_AGE_DAYS} days"
  nix-env --delete-generations "${1:-$DEFAULT_MAX_AGE_DAYS}d"
}

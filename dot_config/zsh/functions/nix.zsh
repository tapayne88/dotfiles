function nix-clean() {
  set -x
  local DEFAULT_MAX_AGE_DAYS="7"

  home-manager expire-generations "-${1:-$DEFAULT_MAX_AGE_DAYS} days"
  nix-env --delete-generations "${1:-$DEFAULT_MAX_AGE_DAYS}d"
}

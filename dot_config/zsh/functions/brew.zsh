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

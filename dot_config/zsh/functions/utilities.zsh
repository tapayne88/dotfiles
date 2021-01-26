# Catch-all for simple utility functions

# ensure ssh server has terminfo for env TERM
function ssh() {
  emulate -L zsh

  local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  env TERM=$LOCAL_TERM ssh "$@"
}

# ctop doesn't like tmux terminfo
function ctop() {
  emulate -L zsh

  local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  env TERM=$LOCAL_TERM ctop "$@"
}

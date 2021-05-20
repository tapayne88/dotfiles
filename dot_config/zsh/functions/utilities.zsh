# Catch-all for simple utility functions

# ensure ssh server has terminfo for env TERM
function ssh() {
  emulate -L zsh

  # local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  env TERM=xterm-256color command ssh "$@"
}

# ctop doesn't like tmux terminfo
function ctop() {
  emulate -L zsh

  # local LOCAL_TERM=$(echo -n "$TERM" | sed -e s/tmux/screen/)
  env TERM=xterm-256color command ctop "$@"
}

# `git` wrapper:
#
#     - `git` with no arguments = `git status`; run `git help` to show what
#       vanilla `git` without arguments would normally show.
#     - `git root` = `echo` repo root.
#     - `git ARG...` = behaves just like normal `git` command.
#
function git() {
  if [ $# -eq 0 ]; then
    command git status
  elif [ "$1" = root ]; then
    shift
    local ROOT
    if [ "$(command git rev-parse --is-inside-git-dir 2> /dev/null)" = true ]; then
      if [ "$(command git rev-parse --is-bare-repository)" = true ]; then
        ROOT="$(command git rev-parse --absolute-git-dir)"
      else
        # Note: This is a good-enough, rough heuristic, which ignores
        # the possibility that GIT_DIR might be outside of the worktree;
        # see:
        # https://stackoverflow.com/a/38852055/2103996
        ROOT="$(command git rev-parse --git-dir)/.."
      fi
    else
      # Git 2.13.0 and above:
      ROOT="$(command git rev-parse --show-superproject-working-tree 2> /dev/null)"
      if [ -z "$ROOT" ]; then
        ROOT="$(command git rev-parse --show-toplevel 2> /dev/null)"
      fi
    fi
    if [ -z "$ROOT" ]; then
      # Not a git repo, print the error message
      command git status
    else
      echo "$ROOT"
    fi
  else
    command git "$@"
  fi
}

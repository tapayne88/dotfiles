function gw() {
  if [ "$1" = "-h" ]; then
    echo "gw - quick way to swap between git worktrees and remain in the same subdirectory, using fzf"
    echo ""
    echo "Usage:"
    echo "   gw <flags> <worktree_name>"
    echo ""
    echo "Flags:"
    echo "   -h     Help, print his help message"
    echo ""
    echo "\`gw\` will show available git worktrees via fzf."
    echo "\`gw master\` will swap to the master worktree in the same subdirectory."
    return
  fi

  if [ "$(git rev-parse --git-dir 2> /dev/null)" = "" ]; then
    echo "not a git repository"
    return 1
  fi

  GIT_PREFIX=$(git rev-parse --show-prefix)

  if [ "$1" != "" ]; then
    for WT in $(git worktree list | awk '{ print $1 }'); do
      if [ "$(basename $WT)" = "$1" ]; then
        cd "$WT/$GIT_PREFIX"
        return
      fi
    done

    echo "no worktree found called $1"
    return 1
  else
    WORKTREE_DIR=$(git worktree list | fzf --height 15 --header "swap worktree" | awk '{ print $1 }')

    if [ "$WORKTREE_DIR" = "" ]; then
      return 1
    fi

    cd "$WORKTREE_DIR/$GIT_PREFIX"
  fi
}

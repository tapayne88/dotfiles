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

function git-worktree-init() {
  if [ "$1" = "-h" ]; then
    echo "git-worktree-init - convert a git repo to worktree setup"
    echo ""
    echo "Usage:"
    echo "   gw <flags>"
    echo ""
    echo "Flags:"
    echo "   -h     Help, print his help message"
    echo ""
    echo "\`git-worktree-init\` will convert the current git repo to a worktree."
    return
  fi

  if [ ! -d ".git" ]; then
    echo "not in root of git repo"
    return 1
  fi

  REPO_DIR=$(pwd)
  PARENT_DIR=$(dirname $REPO_DIR)
  REPO_NAME=$(basename $REPO_DIR)

  TEMP_REPO="$(mktemp -d)/$REPO_NAME"

  # Remove old location files
  echo "moving current repo to $TEMP_REPO"
  cd ..
  mv $REPO_NAME $TEMP_REPO

  # Make new directory structure
  echo "setting up new directory structure"
  mkdir -p "$REPO_NAME/worktrees"
  cp -r "$TEMP_REPO/.git" "$REPO_NAME/.$REPO_NAME.git"

  # Setup hidden actual repo as bare to avoid accidentally checking out a branch
  echo "setting hidden repo as bare"
  cd "$REPO_NAME/.$REPO_NAME.git"
  git config --bool core.bare true

  echo "run \`git worktree add ../worktrees/<worktree_name> <branch>\` to add a worktree"
}

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

  TEMP_REPO="/tmp/$REPO_NAME"

  echo "checking out default branch"
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
  git checkout $DEFAULT_BRANCH > /dev/null 2>&1
  
  # Remove old location files
  echo "moving current repo to /tmp"
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
}

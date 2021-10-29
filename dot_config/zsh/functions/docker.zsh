# Interactively remove docker containers
function drm() {
  # Do we need to sudo?
  docker ps > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    # If we need to sudo then we're not on mac, therefore we likely have GNU tools not BSD,
    # hence the --no-run-if-empty (which BSD seems to have by default)
    command="sudo docker"
    xargs="xargs --no-run-if-empty"
  else
    command="docker"
    xargs="xargs"
  fi
  eval "$command ps --all" | fzf --height 15 --multi --header-lines=1 | awk '{ print $1 }' | eval "$xargs $command rm --force"
}

# Interactively remove docker images
function drmi() {
  # Do we need to sudo?
  docker ps > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    # If we need to sudo then we're not on mac, therefore we likely have GNU tools not BSD,
    # hence the --no-run-if-empty (which BSD seems to have by default)
    command="sudo docker"
    xargs="xargs --no-run-if-empty"
  else
    command="docker"
    xargs="xargs"
  fi
  eval "$command images --all" | fzf --height 15 --multi --header-lines=1 | awk '{ print $3 }' | eval "$xargs $command rmi --force"
}

# Interactively exec a running docker container
function dexe() {
  SHELL_PATH=$1
  if [ -z "$SHELL_PATH" ]; then
    echo "pass shell path as first argument, i.e. drr /bin/bash"
    return 1
  fi

  # Do we need to sudo?
  docker ps > /dev/null 2>&1
  if [ $? -eq 1 ]; then
    # If we need to sudo then we're not on mac, therefore we likely have GNU tools not BSD,
    # hence the --no-run-if-empty (which BSD seems to have by default)
    command="sudo docker"
    xargs="xargs --no-run-if-empty"
  else
    command="docker"
    xargs="xargs"
  fi
  eval "$command ps" | fzf --height 15 --header-lines=1 | awk '{ print $1 }' | eval "$xargs -I '{}' --open-tty $command exec --interactive --tty {} $SHELL_PATH"
}

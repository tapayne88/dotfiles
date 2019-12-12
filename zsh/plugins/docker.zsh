# Interactively remove docker containers
function docker_rm() {
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
  eval "$command ps -a" | fzf --height 15 --multi --header-lines=1 | awk '{ print $1 }' | eval "$xargs $command rm -f"
}

# Interactively remove docker images
function docker_rmi() {
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
  eval "$command images -a" | fzf --height 15 --multi --header-lines=1 | awk '{ print $3 }' | eval "$xargs $command rmi -f"
}

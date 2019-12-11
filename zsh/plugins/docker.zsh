# Interactively remove docker containers
function docker_rm() {
  docker ps -a | fzf --multi --header-lines=1 | awk '{ print $1 }' | xargs docker rm -f
}

# Interactively remove docker images
function docker_rmi() {
  docker images -a | fzf --multi --header-lines=1 | awk '{ print $3 }' | xargs docker rmi -f
}
